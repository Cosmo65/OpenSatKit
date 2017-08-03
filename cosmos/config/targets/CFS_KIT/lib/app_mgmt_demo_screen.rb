################################################################################
# cFS Kit Application Management Demo (AMD)
#
# Notes:
#   1. AMD_INSTRUCT_x variables are used to put text on the demo screen's
#      instruction text box. The AMD_INFO_x variables are used for extra detailed
#      information that is displayed on a separate screen.
#   2. Debug events are enabled for the apps used during the demo.
#
# License:
#   Written by David McComas, licensed under the copyleft GNU General Public
#   License (GPL).
# 
################################################################################

require 'cfs_kit_global'
require 'file_transfer'

################################################################################
## Global Variables
################################################################################

AMD_INFO_APP = "FM"  # App used for informational demos
AMD_LOAD_APP = "MD"  # App used for stop, start, and reloads
AMD_LOAD_APP_FILE = "#{FLT_SRV_DIR}/md.so"

AMD_INFO_DEF = "\n\nNo additional information for this demo step."

################################################################################
## Demo Narrative Text
################################################################################

#
# 1 - Display app info
# 2 - Enable/disable app events
# 3 - Stop an app
# 4 - Start an app
#

# Instruct 0 text is in the file demo screen text file.  It's here to help with the info text.
AMD_INSTRUCT_0 = ["This demo illustrates some basic application management features. Click...",
                  " ",
                  "  <More Info> to obtain more information about the current step",
                  "  <Demo> to issue commands to demonstrate a feature in the current step",
                  "  <Next> to move to the next step",
                  " ",
                  " "]
              
AMD_INFO_0 = AMD_INFO_DEF

AMD_INSTRUCT_1 = ["The App Management and App Summary screens have been opened. Note the",
                  "number of registered apps is less than the tasks because the cFE apps are",
                  "not part of the regsitered app count and some apps have child tasks.",
                  " ",
                  "<Demo> Send CFE_ES QUERY_APP for #{AMD_INFO_APP} which is the same as the",
                  "               'Get App Info' button the App Management screen.",
                  ""]

AMD_INFO_1 = "\n\n\
The App Summary window lists all of the applications that are pre-installed \n\n\
in the kit. The #{FLT_SRV_DIR}/cfe_es_startup.src file defines which apps are loaded\n\n\
during initialization adn these are counted as 'registered apps'. Most of the \n\n\
information in the registered app display comes from the startup script file:\n\n\
File Name, App Name, Entry Point, Priority, Stack Size, and Exception Action.\n\n\
"


# 2 - Enable/disable app events
AMD_INSTRUCT_2 = ["This step shows that app events can be ena/dis. This is convenient",
                  "when debugging an app. <Demo> will cycle through enabling/disabling", 
                  "#{AMD_INFO_APP} info events and sending a #{AMD_INFO_APP} NOOP cmd. The cmd counter increments",
                  "even when you don't see the NOOP event message.",
                  "",
                  "<Demo> Send CFE_EVS DIS_APP_EVENT_TYPE, #{AMD_INFO_APP} NOOP, ",
                  "                Send CFE_EVS ENA_APP_EVENT_TYPE, #{AMD_INFO_APP} NOOP, ",
                  ""]
               
AMD_INFO_2 = "\n\n\
The CFE_EVS ENA_APP_EVENT_TYPE and DIS_APP_EVENT_TYPE command takes a bit mask\n\n\
as a parameter: Bit 0=Debug, 1=Info, 2=Error, 3==Critical. A one will cause the\n\n\
command to take effect.\n\n\n\

The cFE_ES and cFE_EVS debug events are enabled for this demo so more information\n\n\
is displayed during the demoes.\n\n\n\
"

# 3 - Stop an app
AMD_INSTRUCT_3 = ["This step stops the #{AMD_LOAD_APP} app. Notice the Registered app",
                  "count decrements by one after the app is stopped.",
                  "",
                  "<Demo> Send CFE_ES QUERY_APP for #{AMD_LOAD_APP}. Note priority.",
                  "<Demo> Send #{AMD_LOAD_APP} NOOP to show it's operational",
                  "<Demo> Send CFE_ES STOP_APP for #{AMD_LOAD_APP}",
                  "<Demo> Send #{AMD_LOAD_APP} NOOP to show no response"]
AMD_INFO_3 = AMD_INFO_DEF

                    
# 4 - Start an app
AMD_INSTRUCT_4 = ["This step starts the #{AMD_LOAD_APP} app. Notice the Registered app",
                  "count increments by one after the app is stopped.",
                  "",
                  "<Demo> Send CFE_ES START_APP for #{AMD_LOAD_APP}",
                  "<Demo> Send CFE_ES QUERY_APP for #{AMD_LOAD_APP}. Note new priority.",
                  "<Demo> Send #{AMD_LOAD_APP} NOOP to show it's operational",
                  ""]
AMD_INFO_4 = AMD_INFO_DEF


AMD_INSTRUCT_ARRAY = [AMD_INSTRUCT_0, AMD_INSTRUCT_1, AMD_INSTRUCT_2, AMD_INSTRUCT_3, AMD_INSTRUCT_4]
AMD_LAST_STEP = 4

def amd_set_instruct_text(num)

  new_instruct = AMD_INSTRUCT_ARRAY[num]
  
  $instruct1.text = new_instruct[0]
  $instruct2.text = new_instruct[1]
  $instruct3.text = new_instruct[2]
  $instruct4.text = new_instruct[3]
  $instruct5.text = new_instruct[4]
  $instruct6.text = new_instruct[5]
  $instruct7.text = new_instruct[6]

end # amd_set_instruct_text()

################################################################################
## Demo Flow Control
################################################################################

$file_xfer = FileTransfer.new()
$amd_step = 0   # Demo step incremented by Next button
$amd_demo = 0   # Issue command(s) to perform the current demo step

def app_mgmt_demo(screen, button)

  $instruct1  = screen.get_named_widget("Instruct1")
  $instruct2  = screen.get_named_widget("Instruct2")
  $instruct3  = screen.get_named_widget("Instruct3")
  $instruct4  = screen.get_named_widget("Instruct4")
  $instruct5  = screen.get_named_widget("Instruct5")
  $instruct6  = screen.get_named_widget("Instruct6")
  $instruct7  = screen.get_named_widget("Instruct7")

  if (button == "INFO")
  
    display("CFS_KIT APP_MGMT_DEMO_INFO_SCREEN",500,50)    

  elsif (button == "NEXT")
  
    $amd_step += 1
    $amd_demo  = 0
    
    if ($amd_step <= AMD_LAST_STEP)
      amd_set_instruct_text($amd_step)
    end

    case $amd_step
      when 1
        display("CFS_KIT APP_MGMT_SCREEN",500,50)    
        display("CFS_KIT APP_SUMMARY_SCREEN",500,50)    
        cmd("CFE_EVS ENA_APP_EVENT_TYPE with APPNAME CFE_ES, BITMASK 0x01") # Enable debug events
        wait(2) 
        cmd("CFE_EVS ENA_APP_EVENT_TYPE with APPNAME CFE_EVS, BITMASK 0x01") # Enable debug events
      when 2..AMD_LAST_STEP
        # Keep case statement for maintenance
      else
        cmd("CFE_EVS DIS_APP_EVENT_TYPE with APPNAME CFE_EVS, BITMASK 0x01") # Disable debug events
        wait(2) 
        cmd("CFE_EVS DIS_APP_EVENT_TYPE with APPNAME CFE_ES, BITMASK 0x01") # Disable debug events
        $amd_step = 0
        clear("CFS_KIT APP_MGMT_SCREEN")    
        clear("CFS_KIT APP_SUMMARY_SCREEN")    
        clear("CFS_KIT APP_MGMT_DEMO_SCREEN")
        clear("CFS_KIT APP_MGMT_DEMO_INFO_SCREEN")
    end # Step Case
        
  elsif (button == "DEMO")
  
    case $amd_step

      # Lookup a symbol
      when 1
        if ($amd_demo == 0)
          cmd("CFE_ES QUERY_APP with APPLICATION #{AMD_INFO_APP}")

          # Don't increment amd_demo; okay if user repeatedly sends lookup cmd
        end
      
      # 2 - Enable/disable app events
      when 2
        case $amd_demo
          when 0 
            cmd("CFE_EVS DIS_APP_EVENT_TYPE with APPNAME #{AMD_INFO_APP}, BITMASK 0x02") # Disable info events
            $amd_demo += 1
          when 1 
            cmd("#{AMD_INFO_APP} NOOP")
            $amd_demo += 1
          when 2 
            cmd("CFE_EVS ENA_APP_EVENT_TYPE with APPNAME #{AMD_INFO_APP}, BITMASK 0x02") # Enable info events
            $amd_demo += 1
          when 3
            cmd("#{AMD_INFO_APP} NOOP")
            $amd_demo = 0
          else
            $amd_demo = 0
        end # Case $amd_demo

      # 3 - Stop App
      when 3
        case $amd_demo
          when 0
            cmd("CFE_ES QUERY_APP with APPLICATION #{AMD_LOAD_APP}")
            $amd_demo += 1
          when 1
            cmd("#{AMD_LOAD_APP} NOOP")
            $amd_demo += 1
          when 2
            cmd("CFE_ES STOP_APP with APPLICATION #{AMD_LOAD_APP}")
            $amd_demo += 1
          when 3
            cmd("#{AMD_LOAD_APP} NOOP")
            $amd_demo += 1
        end # Case $amd_demo

      # 4 - Start App
      when 4
        if ($amd_demo == 0)
          cmd("CFE_ES START_APP with APPLICATION #{AMD_LOAD_APP}, \
                                     APPENTRYPOINT MD_AppMain, \
                                     APPFILENAME #{AMD_LOAD_APP_FILE}, \
                                     STACKSIZE 16384,\
                                     EXCEPTIONACTION 0, \
                                     PRIORITY 100")
                                     
          $amd_demo += 1
        elsif ($amd_demo == 1)
          cmd("CFE_ES QUERY_APP with APPLICATION #{AMD_LOAD_APP}")
          $amd_demo += 1
        elsif ($amd_demo == 2)
          cmd("#{AMD_LOAD_APP} NOOP")
          # Don't increment $amd_demo, let user continually send noop 
        end

    end # Step Case
  end # Demo
   
end # app_mgmt_demo()

def app_mgmt_demo_more_info(screen)
   
  msg_widget = screen.get_named_widget("msg_box")
  case $amd_step
    when 0
      msg_widget.text = AMD_INFO_0
    when 1
      msg_widget.text = AMD_INFO_1
    when 2
      msg_widget.text = AMD_INFO_2
    when 3
      msg_widget.text = AMD_INFO_3
    when 4
      msg_widget.text = AMD_INFO_4
    else
      msg_widget.text = AMD_INFO_DEF
    end # Case
    
end # app_mgmt_demo_more_info()

