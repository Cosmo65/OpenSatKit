################################################################################
# cFS Kit Performance Monitor Demo (PMD)
#
# Notes:
#   1. PMD_INSTRUCT_x variables are used to put text on the demo screen's
#      text box. The PMD_INFO_x variables are used for extra detailed
#      information that is displayed on a separate screen.
#   2. The performoance monitor feature has been equated to a Logic 
#      Analyzer (LA) so LA is in the comamnd names and in the code.
#   3. Debug events are enabled for the apps used during the demo.
# 
# License:
#   Written by David McComas, licensed under the copyleft GNU General Public
#   License (GPL).
#
################################################################################

require 'cfs_kit_global'
require 'file_transfer'
require 'perf_mon_screen'

################################################################################
## Global Variables
################################################################################

PMD_DAT_FILE = "perf_mon_demo.dat"
PMD_FLT_DAT_FILE = "#{FLT_SRV_DIR}/#{PMD_DAT_FILE}"
PMD_GND_DAT_FILE = "#{GND_SRV_DIR}/#{PMD_DAT_FILE}"
PMD_INFO_DEF = "\n\nNo additional information for this demo step."

PMD_DIR_LIST_FILE = "perf_mon_dir.dat"
PMD_DIR_LIST_FLT_FILE = "#{FLT_SRV_DIR}/#{PMD_DIR_LIST_FILE}"


################################################################################
## Demo Narrative Text
################################################################################

#
# 1 - Configure the filter masks
# 2 - Configure the trigger masks
# 3 - Collect data
#

# Label 0 text is in the performance monitor demo screen text file. It's here to help with the info text.
PMD_INSTRUCT_0 = ["This demo shows how to use the cFS Performance Monitor (CPM) functionality. Code execution",
                  "markers are captured in FSW memory and transferred to a file. The file is dumped to",
                  "the ground and the CPM tool is used to display the captured execution data. Click...",
                  " ",
                  "  <More Info> to obtain more information about the current step",
                  "  <Demo> to issue commands to demonstrate a feature in the current step",
                  "  <Next> to move to the next step"]
              
PMD_INFO_0 = "\n\n\
The cFE Executive Serve (ES) app controls the performance monitor data. The operational steps are \n\n\
  1. Send the START_LA_DATA command to start the data collection \n\
  2. Wait some amount of time for the data to be collected \n\
  3. Send the STOP_LA_DATA command. This writes the data to a file \n\
  4. Transfer the data to the ground \n\
  5. Analyse the data using the cFS Performance Monitor tool. \n\n\

ES configuration parameter CFE_ES_PERF_DATA_BUFFER_SIZE defines amount of memory used to capture execution markers. \n\
The tools\\perfutils-java directory contains the CPM user's guide."

# 2 - Configure the trigger masks
PMD_INSTRUCT_1 = ["Configure the filter masks. The demo uses performance IDs (see More Info for bit mask explanation)",
                  "   FM App     = 39(0x0027)",
                  "   FM_CHILD = 44(0x002C)",
                  "   MD App     = 26(0x001A)",
                  "",
                  " <Demo> Send CFE_ES SET_LA_FILTER_MASK cmd four times with the following",
                  "                 '[filter num]=mask' parameters: [0]=0x04000000, [1]=0x1080, [2]=0, [3]=0"]

PMD_INFO_1 = "\n\n\
There is one bit for each performance marker (ID) and a '1' indicates the ID should be \n\
traced. The masks are arranged in an array and the bits are logically numbered 0..127 \n\
spanning the 32-bit array entries. \n\n\

ES configuration parameter CFE_ES_PERF_MAX_IDS defines the number of performance monitor IDs. \n\
It defaults to 128 which is why the demo page is configured as a 4 dimensional array with 32 \n\
bits per entry."

# 2 - Configure the Trigger Mask
PMD_INSTRUCT_2 = ["This step configures the trigger mask. The Memory Dwell App that runs at 1Hz will be",
                  "used as the trigger to start the data collection.",
                  "",
                  " <Demo> Send CFE_ES SET_LA_TRIG_MASK cmd four times with the following",
                  "                 '[filter num]=mask' parameters: [0]=0x04000000, [1]=0, [2]=0, [3]=0",
                  "",
                  ""]
                     
PMD_INFO_2 = "\n\n\
The trigger mask are structured identically to the filter mask. A '1' indicates to use \n\
an ID as a trigger to start data capture. \n\n\

ES configuration parameter CFE_ES_PERF_MAX_IDS defines the number of \n\
performance monitor IDs. It defaults to 128 which is why the perf mon page \n\
is configured as a 4 dimensional array with 32 bits per entry."

# 3-Collect Data
PMD_INSTRUCT_3 = ["This step collects data. Note the Performance Monitor screen doesn't update during data collection.",
                  "",
                  " <Demo> Send CFE_ES START_LA_DATA cmd to start the data collection.",
                  "",
                  "After 12 seconds CFE_ES STOP_LA_DATA cmd is sent and the data is written to", 
                  "#{PMD_FLT_DAT_FILE}. During the 12s FM commands were issued to create",
                  "interesting trace data. Click <More Info> for details."]
PMD_INFO_3 = "\n\n\
Data is collected for approximately 12 seconds. The sequence of events is:\n\
  - Wait 3s, Send FM Send Directory packet command\n\
  - Wait 3s, Send FM Write Directory to file command\n\
  - Wait 3s, Send FM Send Directory packet command\n\
  - Wait 3s, Send STOP_LA_DATA command\n\n\
"

# 4-Transfer file and use CPM to display the results
PMD_INSTRUCT_4 = ["",
                  "<Demo> Transfer data file to the ground and launch the cFS",
                  "                Performance Monitor (CPM) tool",
                  "",
                  "<More Info> for a how to view the data in the CPM tool",
                  "",
                  ""]
PMD_INFO_4 = "\n\n\
Perform the following steps to import and view the data in the CPM tool:\n\
    1. Select the Log Menu item in the top left and then the Read Log drop\n\
        down menu.\n\
    2. In the file dialogue box navigate to #{GND_SRV_DIR}\n\
        directory\n\ 
    3. Select #{PMD_DAT_FILE} and click Read. \n\
    4. You'll see a couple of status dialogue boxes stating the number of IDs\n\
        (should be 3) and that some inconsistencies exist. This is okay and\n\
        it may or may not be true depending on timing.\n\n\

The total time is roughly 12 seconds and the commanding events will occur \n\
before seconds 3, 6, and 9 because the COSMOS wait commands are not\n\
exactly 3 seconds. \n\n\

There are four rows in the display:\n\
   CPU Activity - This is a summation of all the traced activity. \n\
     oxoooooo1A - MD App - Wakes up at 1Hz. \n\
     oxoooooo27 - FM App - Wakes up TBD. \n\
     oxoooooo2c - FM Child Task - Runs for each command. Notice write directory\n\
                       to file takes longer than the send directory listing to a\n\
                       telemetry packet \n\
"

PMD_INSTRUCT_ARRAY = [PMD_INSTRUCT_0, PMD_INSTRUCT_1, PMD_INSTRUCT_2, PMD_INSTRUCT_3, PMD_INSTRUCT_4]
PMD_LAST_STEP = 4

def pmd_set_instruct_text(num)

  new_instruct = PMD_INSTRUCT_ARRAY[num]
  
  $instruct1.text = new_instruct[0]
  $instruct2.text = new_instruct[1]
  $instruct3.text = new_instruct[2]
  $instruct4.text = new_instruct[3]
  $instruct5.text = new_instruct[4]
  $instruct6.text = new_instruct[5]
  $instruct7.text = new_instruct[6]

end # pmd_set_instruct_text()


################################################################################
## Demo Flow Control
################################################################################

$file_xfer = FileTransfer.new()
$pmd_step = 0   # Demo step incremented by Next button
$pmd_demo = 0   # Issue command(s) to perform the current demo step

def perf_mon_demo(screen, button)

  $instruct1  = screen.get_named_widget("Instruct1")
  $instruct2  = screen.get_named_widget("Instruct2")
  $instruct3  = screen.get_named_widget("Instruct3")
  $instruct4  = screen.get_named_widget("Instruct4")
  $instruct5  = screen.get_named_widget("Instruct5")
  $instruct6  = screen.get_named_widget("Instruct6")
  $instruct7  = screen.get_named_widget("Instruct7")

  if (button == "INFO")
  
    display("CFS_KIT PERF_MON_DEMO_INFO_SCREEN",500,50)    

  elsif (button == "NEXT")
  
    $pmd_step += 1
    $pmd_demo = 0
    
    if ($pmd_step <= PMD_LAST_STEP)
      pmd_set_instruct_text($pmd_step)
    end

    case $pmd_step
      when 1
        display("CFS_KIT PERF_MON_SCREEN",500,50)    
        cmd("CFE_EVS ENA_APP_EVENT_TYPE with APPNAME CFE_ES, BITMASK 0x01") # Enable debug events
      when 2..PMD_LAST_STEP
        # Keep case statement for maintenance
      else
        cmd("CFE_EVS DIS_APP_EVENT_TYPE with APPNAME CFE_ES, BITMASK 0x01") # Disable debug events
        $pmd_step = 0
        clear("CFS_KIT PERF_MON_SCREEN")
        clear("CFS_KIT PERF_MON_DEMO_SCREEN")
        clear("CFS_KIT PERF_MON_DEMO_INFO_SCREEN")
    end # Step Case
  
  elsif (button == "DEMO")
  
    case $pmd_step

      # 1 - Configure the filter masks
      when 1
        if ($pmd_demo == 0)
          # Performance IDs: MD 26, FM 39, FM_CHILD 44
          # [0] = 0x04000000
          # [1] = 0x00001080
          cmd ("CFE_ES SET_LA_FILTER_MASK with FILTERMASKNUM 0, FILTERMASK 0x04000000")  
          wait(1)
          cmd ("CFE_ES SET_LA_FILTER_MASK with FILTERMASKNUM 1, FILTERMASK 0x00001080")  
          wait(1)
          cmd ("CFE_ES SET_LA_FILTER_MASK with FILTERMASKNUM 2, FILTERMASK 0x00000000")  
          wait(1)
          cmd ("CFE_ES SET_LA_FILTER_MASK with FILTERMASKNUM 3, FILTERMASK 0x00000000")  
          # Don't increment pmd_demo; okay if user repeats commands
        end
      
      # 2 - Configure the trigger masks
      when 2
        if ($pmd_demo == 0)
          cmd ("CFE_ES SET_LA_TRIG_MASK with TRIGGERMASKNUM 0, TRIGGERMASK 0x04000000")  
          wait(1)
          cmd ("CFE_ES SET_LA_TRIG_MASK with TRIGGERMASKNUM 1, TRIGGERMASK 0x00000000")  
          wait(1)
          cmd ("CFE_ES SET_LA_TRIG_MASK with TRIGGERMASKNUM 2, TRIGGERMASK 0x00000000")  
          wait(1)
          cmd ("CFE_ES SET_LA_TRIG_MASK with TRIGGERMASKNUM 3, TRIGGERMASK 0x00000000")  
          # Don't increment pmd_demo; okay if user repeats commands
        end

      # 3 - Collect the data 
      when 3
        if ($pmd_demo == 0)
          cmd ("CFE_ES START_LA_DATA with TRIGGERMODE 0")
          wait (3)
          cmd("FM SEND_DIR_PKT with DIRECTORY #{FLT_SRV_DIR}, DIRLISTOFFSET 0")
          wait (3)
          cmd("FM WRITE_DIR_TO_FILE with DIRECTORY #{FLT_SRV_DIR}, FILENAME #{PMD_DIR_LIST_FLT_FILE}")
          wait (3)
          cmd("FM SEND_DIR_PKT with DIRECTORY #{FLT_SRV_DIR}, DIRLISTOFFSET 0")
          wait (3)
          cmd_valid_cnt = tlm("CFE_ES HK_TLM_PKT CMD_VALID_COUNT")
          cmd_error_cnt = tlm("CFE_ES HK_TLM_PKT CMD_ERROR_COUNT")
          seq_cnt = tlm("CFE_ES HK_TLM_PKT CCSDS_SEQUENCE")
          cmd ("CFE_ES STOP_LA_DATA with DATAFILENAME #{PMD_FLT_DAT_FILE}")  
          wait("CFE_ES HK_TLM_PKT CMD_VALID_COUNT == #{cmd_valid_cnt}+1", 10)  # Delay until updated valid cmd count or timeout
          if ( (tlm("CFE_ES HK_TLM_PKT CMD_VALID_COUNT") != (cmd_valid_cnt + 1)) || 
               (tlm("CFE_ES HK_TLM_PKT CMD_ERROR_COUNT") !=  cmd_error_cnt))
            if (tlm("CFE_ES HK_TLM_PKT CCSDS_SEQUENCE") == seq_cnt)
              prompt ("No telemetry received to verify the error. Verify connection and telemetry output filter table.");
            else
              prompt ("Executive Service had an error processing the command. See event message for details.")
            end
          else
            prompt ("Successfully created #{PMD_FLT_DAT_FILE}. Click <Next> to transfer file to COSMOS and luanch the performance analyzer tool.")
          end 
          # Don't increment pmd_demo; allow data repeat of data collection
       end

      # 4 - Transfer file from flight to ground & display in CPM 
      when 4
        if ($pmd_demo == 0)
          # TFTP uses UDP directly without cmd interface so can't use cmd counters to verify execution
          get_file_cnt = tlm("TFTP HK_TLM_PKT GET_FILE_COUNT")
          seq_cnt = tlm("TFTP HK_TLM_PKT CCSDS_SEQUENCE")
          file_xfer = FileTransfer.new()
          file_xfer.get(PMD_FLT_DAT_FILE,PMD_GND_DAT_FILE)
          wait("TFTP HK_TLM_PKT GET_FILE_COUNT == #{get_file_cnt}+1", 10)  # Delay until get file count increments or timeout
          if (tlm("TFTP HK_TLM_PKT CCSDS_SEQUENCE") == seq_cnt)
            prompt ("No telemetry received to verify the error. Verify connection and telemetry output filter table.");
          else
            perf_mon_launch_app(screen, "PERF_MONITOR_TOOL")
          end 
          $pmd_demo += 1
        end

    end # Step Case
  end # Demo button
 
end # perf_mon_demo_main()


def perf_mon_demo_more_info(screen)
   
  msg_widget = screen.get_named_widget("msg_box")
  case $pmd_step
    when 0
      msg_widget.text = PMD_INFO_0
    when 1
      msg_widget.text = PMD_INFO_1
    when 2
      msg_widget.text = PMD_INFO_2
    when 3
      msg_widget.text = PMD_INFO_3
    when 4
      msg_widget.text = PMD_INFO_4
    else
      msg_widget.text = PMD_INFO_DEF
    end # Case
    
end # perf_mon_demo_more_info()

