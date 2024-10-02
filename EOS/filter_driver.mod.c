#include <linux/build-salt.h>
#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(.gnu.linkonce.this_module) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used __section(__versions) = {
	{ 0xdd8f8694, "module_layout" },
	{ 0xbcab6ee6, "sscanf" },
	{ 0x362ef408, "_copy_from_user" },
	{ 0x81b395b3, "down_interruptible" },
	{ 0x2072ee9b, "request_threaded_irq" },
	{ 0xab94b49a, "platform_get_irq" },
	{ 0x93a219c, "ioremap_nocache" },
	{ 0x85bd1608, "__request_region" },
	{ 0xca7a3159, "kmem_cache_alloc_trace" },
	{ 0x428db41d, "kmalloc_caches" },
	{ 0x26a5f002, "platform_get_resource" },
	{ 0xd73deab7, "dma_free_attrs" },
	{ 0x9e7dd428, "platform_driver_unregister" },
	{ 0x6091b333, "unregister_chrdev_region" },
	{ 0xb65e5a32, "class_destroy" },
	{ 0x22e92418, "device_destroy" },
	{ 0x6f638b55, "__platform_driver_register" },
	{ 0x22b90774, "cdev_del" },
	{ 0xa0181a43, "dma_alloc_attrs" },
	{ 0xc4952f09, "cdev_add" },
	{ 0x4ddb27b7, "cdev_alloc" },
	{ 0x7749276a, "device_create" },
	{ 0x2871e975, "__class_create" },
	{ 0xe3ec2f2b, "alloc_chrdev_region" },
	{ 0xdecd0b29, "__stack_chk_fail" },
	{ 0x56470118, "__warn_printk" },
	{ 0xb44ad4b3, "_copy_to_user" },
	{ 0x88db9f48, "__check_object_size" },
	{ 0x96848186, "scnprintf" },
	{ 0xe484e35f, "ioread32" },
	{ 0x24b2eaa9, "dma_mmap_attrs" },
	{ 0x37a0cba, "kfree" },
	{ 0x1035c7c2, "__release_region" },
	{ 0x77358855, "iomem_resource" },
	{ 0xedc03953, "iounmap" },
	{ 0xc1514a3b, "free_irq" },
	{ 0x4a453f53, "iowrite32" },
	{ 0xc5850110, "printk" },
	{ 0xbdfb6dbb, "__fentry__" },
};

MODULE_INFO(depends, "");

MODULE_ALIAS("of:N*T*Cdma0");
MODULE_ALIAS("of:N*T*Cdma0C*");
MODULE_ALIAS("of:N*T*Cdma1");
MODULE_ALIAS("of:N*T*Cdma1C*");
MODULE_ALIAS("of:N*T*Cfilter_core");
MODULE_ALIAS("of:N*T*Cfilter_coreC*");

MODULE_INFO(srcversion, "525685547D22EAB8C8E3CCA");
