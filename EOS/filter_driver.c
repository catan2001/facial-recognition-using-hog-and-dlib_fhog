#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/irq.h>
#include <linux/platform_device.h>
#include <linux/io.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>
#include <linux/version.h>
#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <linux/wait.h>
#include <linux/semaphore.h>

#include <linux/dma-mapping.h>
#include <linux/mm.h>
#include <linux/interrupt.h>
#include <linux/string.h>
#include <linux/errno.h>
#include <linux/of.h>
#include <linux/ioport.h>


MODULE_AUTHOR ("y24_g00");
MODULE_DESCRIPTION("Test Driver for Filter IP.");
MODULE_LICENSE("Dual BSD/GPL");
MODULE_ALIAS("custom: filter IP");

#define DEVICE_NAME "filter"
#define DRIVER_NAME "filter_driver"

//buffer size
#define BUFF_SIZE 100 //??

//sahe 1
#define SAHE1_REG_OFFSET 0
#define READY_REG_OFFSET 0
#define START_REG_OFFSET 1
#define WIDTH_REG_OFFSET 2
#define HEIGHT_REG_OFFSET 12
#define WIDTH_2_REG_OFFSET 23
//sahe2
#define SAHE2_REG_OFFSET 4
#define WIDTH_4_REG_OFFSET 0
#define EFFECTIVE_ROW_LIMIT_REG_OFFSET 8
#define CYCLE_NUM_IN_REG_OFFSET 20
#define CYCLE_NUM_OUT_REG_OFFSET 26
//sahe 3
#define SAHE3_REG_OFFSET 8
#define ROWS_NUM_REG_OFFSET 0
#define BRAM_HEIGHT_REG_OFFSET 10
#define RESET_REG_OFFSET 15

#define BRAM_HEIGHT 16

#define ADDR_FACTOR 4

//a multiple of page size 4096
#define MAX_PKT_LEN 49152 

//*******************FUNCTION PROTOTYPES************************************
static int filter_probe(struct platform_device *pdev);
static int filter_open(struct inode *i, struct file *f);
static int filter_close(struct inode *i, struct file *f);
static ssize_t filter_read(struct file *f, char __user *buf, size_t len, loff_t *off);
static ssize_t filter_write(struct file *f, const char __user *buf, size_t length, loff_t *off);
static ssize_t filter_dma_mmap(struct file *f, struct vm_area_struct *vma_s);
static irqreturn_t dma0_isr(int irq, void*dev_id);
static irqreturn_t dma1_isr(int irq, void*dev_id);
int dma_init(void __iomem *base_address);
u32 dma_simple_write(dma_addr_t TxBufferPtr, u32 max_pkt_len, void __iomem *base_address);
u32 dma_simple_read(dma_addr_t RxBufferPtr, u32 max_pkt_len, void __iomem *base_address);
static int __init filter_init(void);
static void __exit filter_exit(void);
static int filter_remove(struct platform_device *pdev);

//*********************GLOBAL VARIABLES*************************************
struct filter_info 
{
	unsigned long mem_start;
	unsigned long mem_end;
	void __iomem *base_addr;
};

struct filter_dma_info { //info that needs driver to control DMA
  unsigned long mem_start; //base physical addr of DMA 
  unsigned long mem_end; //hight addr
  void __iomem *base_addr; //virtual addr, physical addr mem_start->mem_end are mapped to virt
  int irq_num; //num of irq line
};

static struct cdev *my_cdev;
static dev_t my_dev_id;
static struct class *my_class;
static struct device *my_device_dma0;
static struct device *my_device_dma1;
static struct device *my_device_filter;
static struct filter_dma_info *dma0 = NULL;
static struct filter_dma_info *dma1 = NULL;
static struct filter_info *filter_core = NULL;

DECLARE_WAIT_QUEUE_HEAD(readyQ);
struct semaphore sem;

static struct file_operations my_fops =
{
    .owner = THIS_MODULE,
    .open = filter_open,
    .release = filter_close,
    .read = filter_read,
    .write = filter_write,
    .mmap = (void *)filter_dma_mmap
};

static struct of_device_id filter_of_match[] = 
{
	{ .compatible = "dma0", }, // dma0
	{ .compatible = "dma1", }, // dma1
	{ .compatible = "filter_core", }, // filter_core
	{ /* end of list */ },
};

static struct platform_driver my_driver = {
    .driver = 
	{
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table	= filter_of_match,
	},
	.probe = filter_probe,
	.remove	= filter_remove,
};

MODULE_DEVICE_TABLE(of, filter_of_match);

dma_addr_t tx0_phy_buffer, tx1_phy_buffer;
dma_addr_t rx0_phy_buffer, rx1_phy_buffer;
u32 *tx0_vir_buffer;
u32 *rx0_vir_buffer;
u32 *tx1_vir_buffer;
u32 *rx1_vir_buffer;

//***************************************************************************
// PROBE AND REMOVE
int probe_counter = 0;

static int filter_probe(struct platform_device *pdev)
{
	struct resource *r_mem;
	int rc = 0;

	printk(KERN_INFO "Probing\n");

	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!r_mem) 
	{
		printk(KERN_ALERT "filter_probe: invalid address\n");
		return -ENODEV;
	}

	switch (probe_counter)
	{
		case 0: // dma0
            // Get memory for structure vga_dma_info
			dma0 = (struct filter_dma_info *) kmalloc(sizeof(struct filter_dma_info), GFP_KERNEL);
			if (!dma0)
			{
				printk(KERN_ALERT "filter_probe: Cound not allocate dma0 device\n");
				return -ENOMEM;
			}
			// Put phisical adresses in timer_info structure
			dma0->mem_start = r_mem->start;
			dma0->mem_end   = r_mem->end;

            // Reserve that memory space for this driver
			if(!request_mem_region(dma0->mem_start, dma0->mem_end - dma0->mem_start+1, DRIVER_NAME))
			{
				printk(KERN_ALERT "filter_probe: Couldn't lock memory region at %p\n",(void *)dma0->mem_start);
				rc = -EBUSY;
				goto error1;
			}
			// Remap phisical to virtual adresses

			dma0->base_addr = ioremap(dma0->mem_start, dma0->mem_end - dma0->mem_start + 1);
			if (!dma0->base_addr)
			{
				printk(KERN_ALERT "hog_probe: Could not allocate dma0 iomem\n");
				rc = -EIO;
				goto error2;
			}

            // Get irq num 
            dma0->irq_num = platform_get_irq(pdev, 0);
            if(!dma0->irq_num)
            {
                printk(KERN_ERR "filter_dma0_probe: Could not get IRQ resource\n");
                rc = -ENODEV;
                goto error2;
            }

            if (request_irq(dma0->irq_num, dma0_isr, 0, DEVICE_NAME, dma0)) {
                printk(KERN_ERR "filter_dma0_probe: Could not register IRQ %d\n", dma0->irq_num);
                return -EIO;
                goto error3;
            }
            else {
                printk(KERN_INFO "filter_dma0_probe: Registered IRQ %d\n", dma0->irq_num);
            }

            /* INIT DMA */
            dma_init(dma0->base_addr);
            
			probe_counter++;
			printk(KERN_INFO "hog_probe: dma0 driver registered.\n");
			return 0;
			
            error3:
	            iounmap(dma0->base_addr);

			error2:
			    release_mem_region(dma0->mem_start, dma0->mem_end - dma0->mem_start + 1);
			    kfree(dma0);

			error1:
			    return rc;
		
			break;
			
		case 1: // dma1
            // Get phisical register adress space from device tree
			dma1 = (struct filter_dma_info *) kmalloc(sizeof(struct filter_dma_info), GFP_KERNEL);
			if (!dma1)
			{
				printk(KERN_ALERT "filter_probe: Couldn't not allocate dma1 device\n");
				return -ENOMEM;
			}
			
            // Put phisical adresses in timer_info structure
			dma1->mem_start = r_mem->start;
			dma1->mem_end   = r_mem->end;

            // Reserve that memory space for this driver
			if(!request_mem_region(dma1->mem_start, dma1->mem_end - dma1->mem_start+1, DRIVER_NAME))
			{
				printk(KERN_ALERT "filter_probe: Couldn't lock memory region at %p\n",(void *)dma1->mem_start);
				rc = -EBUSY;
				goto error4;
			}
			// Remap phisical to virtual adresses

			dma1->base_addr = ioremap(dma1->mem_start, dma1->mem_end - dma1->mem_start + 1);
			if (!dma1->base_addr)
			{
				printk(KERN_ALERT "hog_probe: Could not allocate dma1 iomem\n");
				rc = -EIO;
				goto error5;
			}

            // Get irq num 
            dma1->irq_num = platform_get_irq(pdev, 0);
            if(!dma1->irq_num)
            {
                printk(KERN_ERR "filter_dma1_probe: Could not get IRQ resource\n");
                rc = -ENODEV;
                goto error5;
            }

            if (request_irq(dma1->irq_num, dma1_isr, 0, DEVICE_NAME, dma1)) {
                printk(KERN_ERR "filter_dma1_probe: Could not register IRQ %d\n", dma1->irq_num);
                return -EIO;
                goto error6;
            }
            else {
                printk(KERN_INFO "filter_dma1_probe: Registered IRQ %d\n", dma1->irq_num);
            }

            /* INIT DMA */
            dma_init(dma1->base_addr);
            
			probe_counter++;
			printk(KERN_INFO "hog_probe: dma1 driver registered.\n");
			return 0;
			
            error6:
                iounmap(dma1->base_addr);
            error5:
                release_mem_region(dma1->mem_start, dma1->mem_end - dma1->mem_start + 1);
                kfree(dma1);
            error4:
                return rc;;
			
			break;
			
		case 2: // filter_core
			filter_core = (struct filter_info *) kmalloc(sizeof(struct filter_info), GFP_KERNEL);
			if (!filter_core)
			{
				printk(KERN_ALERT "filter_probe: Cound not allocate filter_core\n");
				return -ENOMEM;
			}
			
			filter_core->mem_start = r_mem->start;
			filter_core->mem_end   = r_mem->end;
			if(!request_mem_region(filter_core->mem_start, filter_core->mem_end - filter_core->mem_start+1, DRIVER_NAME))
			{
				printk(KERN_ALERT "filter_core: Couldn't lock memory region at %p\n",(void *)filter_core->mem_start);
				rc = -EBUSY;
				goto error7;
			}
			
			filter_core->base_addr = ioremap(filter_core->mem_start, filter_core->mem_end - filter_core->mem_start + 1);
			if (!filter_core->base_addr)
			{
				printk(KERN_ALERT "filter_core: Could not allocate filter iomem\n");
				rc = -EIO;
				goto error8;
			}
			
			printk(KERN_INFO "filter_core: filter_core driver registered.\n");
			return 0;
			
			error8:
			release_mem_region(filter_core->mem_start, filter_core->mem_end - filter_core->mem_start + 1);
			
			error7:
			return rc;
			
			break;
			
		default:
			printk(KERN_INFO "filter_core: Counter has illegal value. \n");
			return -1;
	}
	return 0;
}	
		
static int filter_remove(struct platform_device *pdev)
{
    u32 reset = 0x00000004;
	switch (probe_counter)
	{
		case 0: // dma0
			printk(KERN_ALERT "filter_remove: dma0 platform driver removed\n");
			iowrite32(reset, dma0->base_addr);
            free_irq(dma0->irq_num, NULL);
			iounmap(dma0->base_addr);
			release_mem_region(dma0->mem_start, dma0->mem_end - dma0->mem_start + 1);
			kfree(dma0);
			break;
			
		case 1: // dma1
			printk(KERN_ALERT "filter_remove: dma1 platform driver removed\n");
			iowrite32(reset, dma1->base_addr);
			iounmap(dma1->base_addr);
            free_irq(dma1->irq_num, NULL);
			release_mem_region(dma1->mem_start, dma1->mem_end - dma1->mem_start + 1);
			kfree(dma1);
			probe_counter--;
			break;
			
		case 2: // filter_core
			printk(KERN_ALERT "filter_remove: filter_core platform driver removed\n");
			iowrite32(0, filter_core->base_addr);
			iounmap(filter_core->base_addr);
			release_mem_region(filter_core->mem_start, filter_core->mem_end - filter_core->mem_start + 1);
			kfree(filter_core);
			probe_counter--;
			break;
			
		default:
			printk(KERN_INFO "filter_remove: Counter has illegal value. \n");
			return -1;
	}
	return 0;
}		

//***************************************************
// IMPLEMENTATION OF FILE OPERATION FUNCTIONS*************************************************

static int filter_open(struct inode *i, struct file *f)
{
    //printk("filter opened\n");
    return 0;
}
static int filter_close(struct inode *i, struct file *f)
{
    //printk("filter closed\n");
    return 0;
}

ssize_t filter_read(struct file *pfile, char __user *buf, size_t length, loff_t *off)
{
	char buff[BUFF_SIZE];
	long int len = 0;
	int filter_val[3];
	int minor = MINOR(pfile->f_inode->i_rdev);
	
	if (minor == 2)
	{
        filter_val[0] = ioread32(filter_core->base_addr + SAHE1_REG_OFFSET);
        filter_val[1] = ioread32(filter_core->base_addr + SAHE2_REG_OFFSET);
        filter_val[2] = ioread32(filter_core->base_addr + SAHE3_REG_OFFSET);
        
        //ready = filter_val[0] & 0x00000001;

        len = scnprintf(buff, BUFF_SIZE, "%x %x %x ", filter_val[0], filter_val[1], filter_val[2]);
        //printk(KERN_INFO "hog_read: ready_reg = %d\n", hog_val);

        if (copy_to_user(buf, buff, len))
        {	
            printk(KERN_ERR "filter_read: Copy to user does not work.\n");
            return -EFAULT;
        }
	}
	return len;
}

ssize_t filter_write(struct file *pfile, const char __user *buf, size_t length, loff_t *off)
{

	char buff[BUFF_SIZE];
    	int ret = 0;
	int minor = MINOR(pfile->f_inode->i_rdev);
	int pos = 0;
	int val = 0;

    	ret = copy_from_user(buff, buf, length);  
	if (ret)
		return -EFAULT;
	buff[length]='\0';
	sscanf(buff, "%d, %d\n", &val, &pos);
	//val -> tx_pkt_len
	//pos -> rx_pkt_len
	if (minor == 2)
	{
        // filter_core
        if (pos == SAHE1_REG_OFFSET)
        {
            //SAHE1
            iowrite32(val, filter_core->base_addr + pos);
        }
        else if(pos == SAHE2_REG_OFFSET)
        {
            //SAHE2
            iowrite32(val, filter_core->base_addr + pos);
        }
        else
        {  
            //SAHE3
            iowrite32(val, filter_core->base_addr + pos);
        }
	}else if(minor == 1){
		dma_simple_write(tx1_phy_buffer, val, dma1->base_addr); // helper function, defined later
		dma_simple_read(rx1_phy_buffer, pos, dma1->base_addr); 
		printk(KERN_INFO "I entered configuration dma1");
		printk(KERN_INFO "tx Phy buffer tx1: %x", tx1_phy_buffer);

	
	}else if(minor == 0){
		dma_simple_write(tx0_phy_buffer, val, dma0->base_addr); // helper function, defined later
		dma_simple_read(rx0_phy_buffer, pos, dma0->base_addr);
		printk(KERN_INFO "I entered configuration dma0");
		printk(KERN_INFO "tx Phy buffer tx0: %x", tx0_phy_buffer);
	}

	return length;
}

static ssize_t filter_dma_mmap(struct file *f, struct vm_area_struct *vma_s)
{
	int ret = 0;
        long length;
	int minor;
	minor = MINOR(f->f_inode->i_rdev);
	printk(KERN_INFO "I ENTERED MMAP!");
	length = vma_s->vm_end - vma_s->vm_start;

	printk(KERN_INFO "vma_end: %ld vma_start: %ld len: %ld\n", vma_s->vm_end, vma_s->vm_start, length);

	if(length > MAX_PKT_LEN)
	{
		printk(KERN_ERR "Trying to mmap more space than it's allocated\n");
		return -EIO;
	}

	switch(minor){
		case 0:
			switch(vma_s->vm_flags & 0x3){
				case VM_WRITE:
				        printk(KERN_INFO "VM_WRITE dma0");	
					ret = dma_mmap_coherent(my_device_dma0, vma_s, tx0_vir_buffer, tx0_phy_buffer, length);	
					printk(KERN_INFO "ovog kurca sto ga printas %llu", tx0_vir_buffer[0]);
					printk(KERN_INFO "bla blab la%x", tx0_vir_buffer[0]);
				break;
					
				case VM_READ: 
					printk(KERN_INFO "VM_READ dma0");	
					ret = dma_mmap_coherent(my_device_dma0, vma_s, rx0_vir_buffer, rx0_phy_buffer, length);	
				break;

				default:
					printk(KERN_ERR "wrong addr\n");
				break;
			}
		break;

		case 1:
			switch(vma_s->vm_flags & 0x3){
				case VM_WRITE: 
					printk(KERN_INFO "VM_WRITE dma1");
					ret = dma_mmap_coherent(my_device_dma1, vma_s, tx1_vir_buffer, tx1_phy_buffer, length);	
				break;
					
				case VM_READ: 
					printk(KERN_INFO "VM_READ dma1");
					ret = dma_mmap_coherent(my_device_dma1, vma_s, rx1_vir_buffer, rx1_phy_buffer, length);	
				break;

				default:
					printk(KERN_ERR "wrong addr\n");
				break;
			}
		break;

		default:
			printk(KERN_ERR "dev does not exist\n");
		break;
	}

	if(ret<0)
	{
		printk(KERN_ERR "memory map failed\n");
		return ret;
	}
	return 0;
}


/****************************************************/
// IMPLEMENTATION OF DMA related functions

static irqreturn_t dma0_isr(int irq, void*dev_id)
{
	u32 IrqStatus;  
	/* Read pending interrupts */
	IrqStatus = ioread32(dma0->base_addr + 4);//read irq status from MM2S_DMASR register
	iowrite32(IrqStatus | 0x00007000, dma0->base_addr + 4);//clear irq status in MM2S_DMASR register
	//(clearing is done by writing 1 on 13. bit in MM2S_DMASR (IOC_Irq)

	printk(KERN_INFO "IRQ HAPPENED!");

	/*printk(KERN_INFO "%llu ", tx0_vir_buffer[0]);
	printk(KERN_INFO "%llu ", tx0_vir_buffer[1]);
	printk(KERN_INFO "%llu ", tx0_vir_buffer[2]);
	printk(KERN_INFO "%llu ", tx0_vir_buffer[3]); */
	/*Send a transaction*/
	//dma_simple_write(tx0_phy_buffer, MAX_PKT_LEN, dma0->base_addr); //My function that starts a DMA transaction
	return IRQ_HANDLED;;
}

static irqreturn_t dma1_isr(int irq, void*dev_id)
{
	u32 IrqStatus;  
	// Read pending interrupts 
	IrqStatus = ioread32(dma1->base_addr + 4);//read irq status from MM2S_DMASR register
	iowrite32(IrqStatus | 0x00007000, dma1->base_addr + 4);//clear irq status in MM2S_DMASR register
	//(clearing is done by writing 1 on 13. bit in MM2S_DMASR (IOC_Irq)
	printk(KERN_INFO "Interrupt DMA1!!");
	//Send a transaction
	//dma_simple_write(tx1_phy_buffer, MAX_PKT_LEN, dma1->base_addr); //My function that starts a DMA transaction
	return IRQ_HANDLED;;
}

int dma_init(void __iomem *base_address)
{
	u32 reset = 0x00000004;
	u32 IOC_IRQ_EN; 
	u32 ERR_IRQ_EN;
	u32 MM2S_DMACR_reg;
	u32 en_interrupt;

	IOC_IRQ_EN = 1 << 12; // this is IOC_IrqEn bit in MM2S_DMACR register
	ERR_IRQ_EN = 1 << 14; // this is Err_IrqEn bit in MM2S_DMACR register

	iowrite32(reset, base_address); // writing to MM2S_DMACR register. Seting reset bit (3. bit)

	MM2S_DMACR_reg = ioread32(base_address); // Reading from MM2S_DMACR register inside DMA
	en_interrupt = MM2S_DMACR_reg | IOC_IRQ_EN | ERR_IRQ_EN;// seting 13. and 15.th bit in MM2S_DMACR
	iowrite32(en_interrupt, base_address); // writing to MM2S_DMACR register  
	return 0;
}

u32 dma_simple_write(dma_addr_t TxBufferPtr, u32 max_pkt_len, void __iomem *base_address) {
	u32 MM2S_DMACR_reg;

	MM2S_DMACR_reg = ioread32(base_address); // READ from MM2S_DMACR register

	iowrite32(0x1 |  MM2S_DMACR_reg, base_address); // set RS bit in MM2S_DMACR register (this bit starts the DMA)

	iowrite32((u32)TxBufferPtr, base_address + 24); // Write into MM2S_SA register the value of TxBufferPtr.
	// With this, the DMA knows from where to start.

	iowrite32(max_pkt_len, base_address + 40); // Write into MM2S_LENGTH register. This is the length of a tranaction.
	// In our case this is the size of the image (640*480*4)
	return 0;
}

u32 dma_simple_read(dma_addr_t RxBufferPtr, u32 max_pkt_len, void __iomem *base_address) {

	u32 S2MM_DMACR_reg;

	S2MM_DMACR_reg = ioread32(base_address + 48); // READ from S2MM_DMACR register

	iowrite32(0x1 |  S2MM_DMACR_reg, base_address + 48); // set RS bit in S2MM_DMACR register (this bit starts the DMA)

	iowrite32((u32)RxBufferPtr, base_address + 72); // Write into S2MM_SA register the value of RxBufferPtr.
	// With this, the DMA knows from where to start.

	iowrite32(max_pkt_len, base_address + 88); // Write into MM2S_LENGTH register. This is the length of a tranaction.
	// In our case this is the size of the image (640*480*4)
	return 0;
}
//***************************************************
// INIT AND EXIT FUNCTIONS OF THE DRIVER

static int __init filter_init(void)
{
    int ret = 0;
	int i = 0;

	printk(KERN_INFO "\n");
	printk(KERN_INFO "hog driver starting insmod.\n");

	if (alloc_chrdev_region(&my_dev_id, 0, 3, "hog_region") < 0)
	{
		printk(KERN_ERR "failed to register char device\n");
		return -1;
	}
	printk(KERN_INFO "char device region allocated\n");

	my_class = class_create(THIS_MODULE, "hog_class");
	
	if (my_class == NULL)
	{
		printk(KERN_ERR "failed to create class\n");
		goto fail_0;
	}
	printk(KERN_INFO "class created\n");
	my_device_dma0 = device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id), 0), NULL, "dma0");
	if (my_device_dma0 == NULL) 
	{
		printk(KERN_ERR "failed to create device dma0\n");
		goto fail_1;
	}
	printk(KERN_INFO "device created - dma0\n");

	my_device_dma1 = device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id), 1), NULL, "dma1"); 
	if (my_device_dma1 == NULL) 
	{
		printk(KERN_ERR "failed to create device dma1\n");
		goto fail_2;
	}
	printk(KERN_INFO "device created - dma1\n");

	my_device_filter = device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id), 2), NULL, "filter_core"); 
	if (my_device_filter == NULL) 
	{
		printk(KERN_ERR "failed to create device filter_core\n");
		goto fail_3;
	}
	printk(KERN_INFO "device created - filter_core\n");

	my_cdev = cdev_alloc();
	my_cdev->ops = &my_fops;
	my_cdev->owner = THIS_MODULE;

	if (cdev_add(my_cdev, my_dev_id, 3) == -1)
	{
		printk(KERN_ERR "failed to add cdev\n");
		goto fail_4;
	}
	printk(KERN_INFO "cdev added\n");

	if (dma_set_coherent_mask(my_device_dma0, DMA_BIT_MASK(32))) {
		printk(KERN_ERR "Bad Mask!\n");
		goto fail_5;
	}

    	tx0_vir_buffer = dma_alloc_coherent(my_device_dma0, MAX_PKT_LEN, &tx0_phy_buffer, GFP_DMA | GFP_KERNEL);

	if (dma_set_coherent_mask(my_device_dma1, DMA_BIT_MASK(32))) {
		printk(KERN_ERR "Bad Mask!\n");
		goto fail_5;
	}
	
	tx1_vir_buffer = dma_alloc_coherent(my_device_dma1, MAX_PKT_LEN, &tx1_phy_buffer, GFP_DMA | GFP_KERNEL);
		
	rx0_vir_buffer = dma_alloc_coherent(my_device_dma0, MAX_PKT_LEN, &rx0_phy_buffer, GFP_DMA | GFP_KERNEL);
	rx1_vir_buffer = dma_alloc_coherent(my_device_dma1, MAX_PKT_LEN, &rx1_phy_buffer, GFP_DMA | GFP_KERNEL);
	
	printk(KERN_INFO "Hello dumb");
	if((!tx0_vir_buffer || !tx1_vir_buffer) || (!rx0_vir_buffer || !rx1_vir_buffer)){
		printk(KERN_ALERT "dma_init: Could not allocate dma_alloc_coherent for img");
		goto fail_5;
	}
	else
		printk("dma_init: Successfully allocated memory for dma transaction buffer\n");
	
	for (i = 0; i < MAX_PKT_LEN/4;i++){
		tx0_vir_buffer[i] = 0x00000000;
		tx1_vir_buffer[i] = 0x00000000;

		rx0_vir_buffer[i] = 0x00000000;
		rx1_vir_buffer[i] = 0x00000000;
	}
	printk(KERN_INFO "dma_init: DMA memory reset.\n");

	return platform_driver_register(&my_driver);

	fail_5:
		cdev_del(my_cdev);
	fail_4:
		device_destroy(my_class, MKDEV(MAJOR(my_dev_id),2));
	fail_3:
		device_destroy(my_class, MKDEV(MAJOR(my_dev_id),1));
	fail_2:
		device_destroy(my_class, MKDEV(MAJOR(my_dev_id),0));
	fail_1:
		class_destroy(my_class);
	fail_0:
		unregister_chrdev_region(my_dev_id, 3);
	return -1;
}

static void __exit filter_exit(void)
{
	//Reset DMA memory
	int i = 0;
	for (i = 0; i < MAX_PKT_LEN/4; i++){ 
		tx0_vir_buffer[i] = 0x00000000;
		tx1_vir_buffer[i] = 0x00000000;
		
		rx0_vir_buffer[i] = 0x00000000;
		rx1_vir_buffer[i] = 0x00000000;
	}
	printk(KERN_INFO "dma_exit: DMA memory reset\n");

	printk(KERN_INFO "hog driver starting rmmod.\n");
	platform_driver_unregister(&my_driver);
	cdev_del(my_cdev);
	
	device_destroy(my_class, MKDEV(MAJOR(my_dev_id),2));
	device_destroy(my_class, MKDEV(MAJOR(my_dev_id),1));
	device_destroy(my_class, MKDEV(MAJOR(my_dev_id),0));
	class_destroy(my_class);

	dma_free_coherent(my_device_dma0, MAX_PKT_LEN, tx0_vir_buffer, tx0_phy_buffer);
	dma_free_coherent(my_device_dma1, MAX_PKT_LEN, tx1_vir_buffer, tx1_phy_buffer);

	dma_free_coherent(my_device_dma0, MAX_PKT_LEN, rx0_vir_buffer, rx0_phy_buffer);
	dma_free_coherent(my_device_dma1, MAX_PKT_LEN, rx1_vir_buffer, rx1_phy_buffer);
	
	unregister_chrdev_region(my_dev_id, 3);
	printk(KERN_INFO "hog driver exited.\n");
}

module_init(filter_init);
module_exit(filter_exit);
