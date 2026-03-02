# Printer-script

It bothered me that Intune had no simple solution of pushing out printers automatically when Universal Print isn't an option in an environment. As a tech at an MSP this was a common problem. Here's a small script to solve that issue.

First download the powershell script Intuneprinsterscript.ps1

Replace comments for organization purposes if you plan to deploy multiple different printers.

These 5 lines you will need to change:

$PrinterName = "Printer name" # Change this to what you want your printer name to show up as

$PortName    = "IP_192.168.1.10" # Change this to the IP_IP of your printer

$PrinterIP   = "192.168.1.10" # Change this to the IP of your printer

$DriverName  = "Printerdrive name"   # Change this to match exact installed driver name
  To confirm this, you can test by installing the printer, running Get-PrinterDriver in powershell and finding the name there. For example, we will use the printer model Canon imageFORCE C5140. After downloading the drivers we can see 'Canon Generic Plus PCL6' is the driver name.
  <img width="1034" height="318" alt="image" src="https://github.com/user-attachments/assets/e9092a96-41cd-424c-97e1-407056fc98c7" />

$InfPath = Join-Path $ScriptFolder "Printerdriver.inf" # Change this to the printer driver you are using.
  To confirm this, you can find the proper .INF in the extracted files. For example with a Canon imageFORCE C5140 we see this:
  <img width="706" height="93" alt="image" src="https://github.com/user-attachments/assets/95eab45f-f2ee-4702-9e98-2fc394456674" /> 
  
So it would be CNP60MA64.inf.

Once you have all that filled out you can save it and put them all in the same folder.

<img width="836" height="362" alt="image" src="https://github.com/user-attachments/assets/a4d38d1d-f791-4047-ac09-f612da858ee2" />

*If you need to test further, you can remove the printers through control panel and remove the driver using Remove-PrinterDriver 'Driver name'. Eg. Remove-PrinterDriver 'Canon Generic Plus PCL6' following the previous example.*

Since we are using Intune we will need to use the Microsoft Win32 Content Prep Tool to man an .intunewin package. You can follow this: https://cloudinfra.net/how-to-create-an-intunewin-file/

Once you have the proper Intune file you can upload it as an app in Microsoft Intune admin center. In this example I uploaded printertest3.intunewin but yours can be named whatever you like. Just keep note of the name in the next steps.

<img width="911" height="810" alt="image" src="https://github.com/user-attachments/assets/304e27dd-e635-445a-827c-9a39a7bcf4d7" />

Here is what you want to set the Program options to. Make sure to have -ExecutionPolicy Bypass as otherwise it may not install properly

<img width="1389" height="861" alt="image" src="https://github.com/user-attachments/assets/17e642b7-248e-416e-b92b-a00bfc518d35" />

Requirement options have not mattered to me. Then you want it to detect successful or non successful installation using registry keys. Set the key and value to the name of the printer.

<img width="1686" height="866" alt="image" src="https://github.com/user-attachments/assets/fa036f77-7c09-40e6-b0b5-411c32074dfe" />

Then you can just save and confirm.

You'll also have apply this to users or groups within Intune but I'll leave that for you to figure out. Thanks all!



