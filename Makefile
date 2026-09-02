TARGET := iphone:clang:14.5:13.0
INSTALL_TARGET_PROCESSES = WebServerApp

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = WebServerApp

WebServerApp_FILES = main.m XXAppDelegate.m XXRootViewController.m HTTPServer.m
WebServerApp_FRAMEWORKS = UIKit Foundation WebKit CFNetwork Security
WebServerApp_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk
