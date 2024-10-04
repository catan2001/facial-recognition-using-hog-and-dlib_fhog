#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/irq.h>
#include <linux/platform_device.h>
#include <asm/io.h>
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

MODULE_AUTHOR ("y24_g00");
MODULE_DESCRIPTION("Test Driver for HOG IP.");
MODULE_LICENSE("Dual BSD/GPL");
MODULE_ALIAS("custom: HOG IP");

#define DEVICE_NAME "HOG"
#define DRIVER_NAME "HOG_driver"

//buffer size
#define BUFF_SIZE 100

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

//*******************FUNCTION PROTOTYPES************************************
static int HOG_probe(struct platform_device *pdev);
static int HOG_open(struct inode *i, struct file *f);
static int HOG_close(struct inode *i, struct file *f);
static ssize_t HOG_read(struct file *f, char __user *buf, size_t len, loff_t *off);
static ssize_t HOG_write(struct file *f, const char __user *buf, size_t length, loff_t *off);
static int __init HOG_init(void);
static void __exit HOG_exit(void);
static int HOG_remove(struct platform_device *pdev);

//*********************GLOBAL VARIABLES*************************************
struct HOG_info 
{
	unsigned long mem_start;
	unsigned long mem_end;
	void __iomem *base_addr;
};

static struct cdev *my_cdev;
static dev_t my_dev_id;
static struct class *my_class;

static struct HOG_info *hog_core = NULL;

static struct file_operations my_fops =
{
    .owner = THIS_MODULE,
    .open = HOG_open,
    .release = HOG_close,
    .read =HOG_read,
    .write = HOG_write
};

static struct of_device_id hog_of_match[] = 
{
	{ .compatible = "filter_core", }, // filter
	{ /* end of list */ },
};

static struct platform_driver my_driver = {
    .driver = 
	{
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table	= hog_of_match,
	},
	.probe = HOG_probe,
	.remove	= HOG_remove,
};

MODULE_DEVICE_TABLE(of, hog_of_match);

//***************************************************************************
// PROBE AND REMOVE
int probe_counter = 0;

static int HOG_probe(struct platform_device *pdev)
{
	struct resource *r_mem;
	int rc = 0;

	printk(KERN_INFO "Probing\n");

	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!r_mem) 
	{
		printk(KERN_ALERT "HOG_probe: invalid address\n");
		return -ENODEV;
	}

	switch (probe_counter)
	{
		case 0: // hough_core
			hog_core = (struct HOG_info *) kmalloc(sizeof(struct HOG_info), GFP_KERNEL);
			if (!hog_core)
			{
				printk(KERN_ALERT "hog_probe: Cound not allocate hog_core\n");
				return -ENOMEM;
			}
			
			hog_core->mem_start = r_mem->start;
			hog_core->mem_end   = r_mem->end;
			if(!request_mem_region(hog_core->mem_start, hog_core->mem_end - hog_core->mem_start+1, DRIVER_NAME))
			{
				printk(KERN_ALERT "hog_probe: Couldn't lock memory region at %p\n",(void *)hog_core->mem_start);
				rc = -EBUSY;
				goto error7;
			}
			
			hog_core->base_addr = ioremap(hog_core->mem_start, hog_core->mem_end - hog_core->mem_start + 1);
			if (!hog_core->base_addr)
			{
				printk(KERN_ALERT "hog_probe: Could not allocate hog iomem\n");
				rc = -EIO;
				goto error8;
			}
			
			printk(KERN_INFO "hog_probe: hog_core driver registered.\n");
			return 0;
			
			error8:
			release_mem_region(hog_core->mem_start, hog_core->mem_end - hog_core->mem_start + 1);
			
			error7:
			return rc;
			
			break;
			
		default:
			printk(KERN_INFO "hog_probe: Counter has illegal value. \n");
			return -1;
	}
	return 0;
}	
		
static int HOG_remove(struct platform_device *pdev)
{
	switch (probe_counter)
	{
		case 0: // hough_core
			printk(KERN_ALERT "hog_remove: hog_core platform driver removed\n");
			iowrite32(0, hog_core->base_addr);
			iounmap(hog_core->base_addr);
			release_mem_region(hog_core->mem_start, hog_core->mem_end - hog_core->mem_start + 1);
			kfree(hog_core);
			break;
			
		default:
			printk(KERN_INFO "hog_remove: Counter has illegal value. \n");
			return -1;
	}
	return 0;
}		

//***************************************************
// IMPLEMENTATION OF FILE OPERATION FUNCTIONS*************************************************

static int HOG_open(struct inode *i, struct file *f)
{
    //printk("HOG opened\n");
    return 0;
}
static int HOG_close(struct inode *i, struct file *f)
{
    //printk("HOG closed\n");
    return 0;
}

ssize_t HOG_read(struct file *pfile, char __user *buf, size_t length, loff_t *off)
{
	char buff[BUFF_SIZE];
	long int len = 0;
	int hog_val[3];
	int minor = MINOR(pfile->f_inode->i_rdev);
	
	switch (minor)
	{
		case 0: // hough_core
			hog_val[0] = ioread32(hog_core->base_addr + SAHE1_REG_OFFSET);
			hog_val[1] = ioread32(hog_core->base_addr + SAHE2_REG_OFFSET);
			hog_val[2] = ioread32(hog_core->base_addr + SAHE3_REG_OFFSET);

			len = scnprintf(buff, BUFF_SIZE, "%d %d %d ", hog_val[0], hog_val[1], hog_val[2]);

			if (copy_to_user(buf, buff, len))
			{	
				printk(KERN_ERR "hog_read: Copy to user does not work.\n");
				return -EFAULT;
			}
			break;

		default:
			printk(KERN_ERR "hog_read: Invalid minor. \n");
	}	
	return len;
}

ssize_t HOG_write(struct file *pfile, const char __user *buf, size_t length, loff_t *off)
{
	char buff[BUFF_SIZE];
	int minor = MINOR(pfile->f_inode->i_rdev);
	int pos = 0;
	int val = 0;
	
	if (copy_from_user(buff, buf, length))
		return -EFAULT;
	buff[length]='\0';

	sscanf(buff, "%d, %d\n", &val, &pos);
	
	switch (minor)
	{
		case 0: // hough_core
			if (pos == SAHE1_REG_OFFSET)
			{
				iowrite32(val, hog_core->base_addr + pos);
			}
			else if(pos == SAHE2_REG_OFFSET)
			{
				iowrite32(val, hog_core->base_addr + pos);
			}
			else
			{
				iowrite32(val, hog_core->base_addr + pos);
			}
			break;
			
		default:
			printk(KERN_INFO "hough_write: Invalid minor. \n");
	}
	return length;
}

//***************************************************
// INIT AND EXIT FUNCTIONS OF THE DRIVER

static int __init HOG_init(void)
{
	printk(KERN_INFO "\n");
	printk(KERN_INFO "hog driver starting insmod.\n");

	if (alloc_chrdev_region(&my_dev_id, 0, 1, "hog_region") < 0)
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

	if (device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id), 0), NULL, "hog_core") == NULL) 
	{
		printk(KERN_ERR "failed to create device hog_core\n");
		goto fail_1;
	}
	printk(KERN_INFO "device created - hog_core\n");

	my_cdev = cdev_alloc();
	my_cdev->ops = &my_fops;
	my_cdev->owner = THIS_MODULE;

	if (cdev_add(my_cdev, my_dev_id, 1) == -1)
	{
		printk(KERN_ERR "failed to add cdev\n");
		goto fail_5;
	}
	printk(KERN_INFO "cdev added\n");
	printk(KERN_INFO "hog driver initialized.\n");

	return platform_driver_register(&my_driver);

	fail_5:
		device_destroy(my_class, MKDEV(MAJOR(my_dev_id),3));
	fail_1:
		class_destroy(my_class);
	fail_0:
		unregister_chrdev_region(my_dev_id, 1);
	return -1;
}

static void __exit HOG_exit(void)
{
	printk(KERN_INFO "hog driver starting rmmod.\n");
	platform_driver_unregister(&my_driver);
	cdev_del(my_cdev);

	device_destroy(my_class, MKDEV(MAJOR(my_dev_id),0));
	class_destroy(my_class);
	unregister_chrdev_region(my_dev_id, 1);
	printk(KERN_INFO "hog driver exited.\n");
}

module_init(HOG_init);
module_exit(HOG_exit);
