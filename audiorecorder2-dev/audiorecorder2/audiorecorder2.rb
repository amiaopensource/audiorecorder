require 'yaml'
require 'json'

# Recording Variables
if RUBY_PLATFORM.include?('linux')
  Drawfontpath = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'
end

FILTER_CHAIN = "asplit=6[out1][a][b][c][d][e],\
[e]showvolume=w=700:c=0xff0000:r=30[e1],\
[a]showfreqs=mode=bar:cmode=separate:size=300x300:colors=magenta|yellow[a1],\
[a1]drawbox=12:0:3:300:white@0.2[a2],[a2]drawbox=66:0:3:300:white@0.2[a3],[a3]drawbox=135:0:3:300:white@0.2[a4],[a4]drawbox=202:0:3:300:white@0.2[a5],[a5]drawbox=271:0:3:300:white@0.2[aa],\
[b]avectorscope=s=300x300:r=30:zoom=5[b1],\
[b1]drawgrid=x=150:y=150:c=white@0.3[bb],\
[c]showspectrum=s=400x600:slide=scroll:mode=combined:color=rainbow:scale=lin:saturation=4[cc],\
[d]astats=metadata=1:reset=1,adrawgraph=lavfi.astats.Overall.Peak_level:max=0:min=-30.0:size=700x256:bg=Black[dd],\
[dd]drawbox=0:0:700:42:hotpink@0.2:t=42[ddd],\
[aa][bb]vstack[aabb],[aabb][cc]hstack[aabbcc],[aabbcc][ddd]vstack[aabbccdd],[e1][aabbccdd]vstack[z],\
[z]drawtext=fontfile=#{Drawfontpath}: text='%{pts \\: hms}':x=460: y=50:fontcolor=white:fontsize=30:box=1:boxcolor=0x00000000@1[fps],[fps]fps=fps=30[out0]"

# Set Configuration
sox_channels = '1 2'
ffmpeg_channels = 'stereo'
$codec_choice = 'pcm_s24le'
$soxbuffer = '50000'
$sample_rate_choice = '96000'

# Load options from config file
configuration_file = File.expand_path('~/.audiorecorder2.conf')
if ! File.exist?(configuration_file)
  config_options = "destination:\nsamplerate:\nchannels:\ncodec:\norig:\nhist:\nbext:"
  File.write(configuration_file, config_options)
end
config = YAML::load_file(configuration_file)
$outputdir = config['destination']
$sample_rate_choice = config['samplerate']
sox_channels = config['channels']
$codec_choice = config['codec']
$originator = config['orig']
$history = config['hist']
$embedbext = config['bext']

#BWF Metaedit Function
def EmbedBEXT(targetfile)
  moddatetime = File.mtime(targetfile)
  moddate = moddatetime.strftime("%Y-%m-%d")
  modtime = moddatetime.strftime("%H:%M:%S")
  bwfmetaeditpath = 'bwfmetaedit'

  #Get Input Name for Description and OriginatorReference
  file_name = File.basename(targetfile)
  originatorreference = File.basename(targetfile, '.wav')
  if originatorreference.length > 32
    originatorreference = "See Description for Identifiers"
  end
  bwfcommand = bwfmetaeditpath + ' --reject-overwrite ' + '--Description=' + "'" + file_name + "'"  + ' --Originator=' + "'" + $originator + "'" + ' --History=' + "'" + $history + "'" + ' --OriginatorReference=' + "'" + originatorreference + "'" + ' --OriginationDate=' + moddate + ' --OriginationTime=' + modtime + ' --MD5-Embed ' + "'" + targetfile + "'"
  system(bwfcommand)
end

#Function for adjusting buffer
def BufferCheck(sr)
  if sr == '96000'
    $soxbuffer = '50000'
  elsif sr == '48000'
    $soxbuffer = '25000'
  elsif sr == '44100'
    $soxbuffer == '23000'  
  end
end

# GUI App
Shoes.app(title: "AudioRecorder2", width: 600, height: 500) do
  style Shoes::Para, font: "Helvetica"
  background aliceblue
  @logo = image("Resources/audiorecorder_small.png", left: 160)

    def PostRecord(targetfile)
      window(title: "Post-Record Options", width: 600, height: 500) do
        style Shoes::Para, font: "Helvetica"
        background aliceblue
        trimcheck = nil
        @pretrim = $outputdir + '/' + File.basename(targetfile, File.extname(targetfile)) + '_untrimmed' + '.wav'
        @finaloutput = targetfile
        stack margin: 15 do
          waveform = image("AUDIORECORDERTEMP.png")
        end
        @start_trim = nil
        @end_trim_length = nil

        def SetUpTrim(input)
          ffprobe_command = 'ffprobe -print_format json -show_streams ' + "'" + input + "'"
          $ffprobeout = JSON.parse(`#{ffprobe_command}`)
          @duration_json = $ffprobeout['streams'][0]['duration']
          @duration =@duration_json.to_f
          if ! @end_trim_length.nil? &&  @start_trim_length != "AUTO"
            $end_trim_opt = @duration - @end_trim_length - @start_trim_length
          elsif ! @end_trim_length.nil?
            $end_trim_opt = @duration - @end_trim_length
          end
          if @start_trim_length != "AUTO"
            $start_trim_opt = ' -ss ' + @start_trim_length.to_s
          end
        end
        stack do
          para "Press 'Preview' to hear the file you recorded.\nTo trim file, enter the amount (in seconds) to trim from the start and end of the file and press 'Trim'.\nIf 'Start Trim' is left blank, auto-trim will be applied to start of file.  If no trim at start is desired enter '0'. After trimming, a preview window will open for your new file.  Trim can be run as many times as is neccessary.\nPress 'Finish' to quit"
        end
        flow do
          @start_trim_length = "AUTO"
          para 'Start Trim'
          start_trim_input = edit_line text = @start_trim_length do
            if start_trim_input.text.downcase == "auto"
              @start_trim_length = "AUTO"
            else
              @start_trim_length = start_trim_input.text.to_f
            end
          end
        end
        flow do
          para 'End Trim'
          end_trim_input = edit_line do
            @end_trim_length = end_trim_input.text.to_f
          end
        end
        flow do
          preview = button "Preview"
          preview.click do
            if trimcheck.nil?
              command = 'mpv --force-window --no-terminal --keep-open=yes --title="Preview" --geometry=620x620 -lavfi-complex "[aid1]asplit=3[ao][a][b],[a]showwaves=600x240:n=1[a1],[a1]drawbox=0:0:600:240:t=120[a2],[b]showwaves=600x240:mode=cline:colors=0x00FFFF:split_channels=1[b2],[a2][b2]overlay[vo]" ' + '"' + @finaloutput + '"'
              system(command)
            else
              command = 'mpv --force-window --no-terminal --keep-open=yes --title="Preview" --geometry=620x620 -lavfi-complex "[aid1]asplit=3[ao][a][b],[a]showwaves=600x240:n=1[a1],[a1]drawbox=0:0:600:240:t=120[a2],[b]showwaves=600x240:mode=cline:colors=0x00FFFF:split_channels=1[b2],[a2][b2]overlay[vo]" ' + '"'+ @pretrim + '"'
              system(command)
            end
          end 
          trim = button "Trim"
          trim.click do
            #set up trim
            if trimcheck.nil?
              SetUpTrim(@finaloutput)
              File.rename(@finaloutput, @pretrim)
              trimcheck = 1
            else
              SetUpTrim(@pretrim)
            end
            if @start_trim_length == "AUTO"
              if ! @end_trim_length.nil? && @end_trim_length != 0.0
                precommand = 'ffmpeg -i ' + '"' + @pretrim + '"' + ' -af silenceremove=start_threshold=-57dB:start_duration=1:start_periods=1 -f wav -c:a ' + $codec_choice  + ' -ar ' + $sample_rate_choice + ' -y -rf64 auto ' + 'INTERMEDIATE.wav'
                system(precommand)
                SetUpTrim('INTERMEDIATE.wav')
                postcommand = 'ffmpeg -i INTERMEDIATE.wav -c copy -y -rf64 auto ' + ' -t ' + $end_trim_opt.to_s + ' "' + @finaloutput + '"'
                system(postcommand)
                File.delete('INTERMEDIATE.wav')
              else
                command = 'ffmpeg -i ' + '"' + @pretrim + '"' + ' -af silenceremove=start_threshold=-57dB:start_duration=1:start_periods=1 -f wav -c:a ' + $codec_choice  + ' -ar ' + $sample_rate_choice + ' -y -rf64 auto ' + '"' + @finaloutput + '"'
                system(command)
              end
            else
              if ! @end_trim_length.nil? && @end_trim_length != 0.0
                command = 'ffmpeg ' + $start_trim_opt + ' -i ' + '"' + @pretrim + '"' + ' -c copy -y -rf64 auto ' + ' -t ' + $end_trim_opt.to_s + ' "' + @finaloutput + '"'
                system(command)
              else
                command = 'ffmpeg ' + $start_trim_opt + ' -i ' + '"' + @pretrim + '"' + ' -c copy -y -rf64 auto ' + ' "' + @finaloutput + '"'              
                system(command)
              end
            end
            command = 'mpv --force-window --no-terminal --keep-open=yes --title="Preview" --geometry=620x620 -lavfi-complex "[aid1]asplit=3[ao][a][b],[a]showwaves=600x240:n=1[a1],[a1]drawbox=0:0:600:240:t=120[a2],[b]showwaves=600x240:mode=cline:colors=0x00FFFF:split_channels=1[b2],[a2][b2]overlay[vo]" ' + '"' + @finaloutput + '"'
            system(command)
          end
          close = button "Finish"
          close.click do
            close()
          end
        end
      end
    end

  flow margin: 10 do
    para "Select Channel(s)"
    if sox_channels == '1 2'
      sox_channels_saved = '1 and 2'
    else
      sox_channels_saved = sox_channels
    end
    channels = list_box items: ["1", "2", "1 and 2"],
    width: 100, choose: sox_channels_saved do |list|
      if list.text == '1 and 2'
        sox_channels = '1 2'
      else
        sox_channels = list.text
      end
      if sox_channels == "1 2"
        ffmpeg_channels = 'stereo'
      else
        ffmpeg_channels = 'mono'
      end
    end

    para "Sample Rate"
    if $sample_rate_choice == '44100'
      sample_rate_saved = "44.1 kHz"
    elsif $sample_rate_choice == '48000'
      sample_rate_saved = "48 kHz"
    elsif $sample_rate_choice == '96000'
      sample_rate_saved = "96 kHz"
    end  
    samplerate = list_box items: ["44.1 kHz", "48 kHz", "96 kHz"],
    width: 100, choose: sample_rate_saved do |list|
      if list.text == '44.1 kHz'
        $sample_rate_choice = '44100'
      elsif list.text == '48 kHz'
        $sample_rate_choice = '48000'
      elsif list.text == '96 kHz'
        $sample_rate_choice = '96000'
      end
    end

    para "Bit Depth"
    if $codec_choice == 'pcm_s16le'
      codec_saved = "16 bit"
    elsif $codec_choice == 'pcm_s24le'
      codec_saved = "24 bit"  
    end
    bitdepth = list_box items: ["16 bit", "24 bit"],
    width: 100, choose: codec_saved do |list|
      if list.text == '16 bit'
        $codec_choice = 'pcm_s16le'
      elsif list.text == '24 bit'
        $codec_choice = 'pcm_s24le'
      end      
    end
  end

  stack margin: 10 do
    button "Choose Output Directory" do
      $outputdir = ask_open_folder
      @destination.replace "#{$outputdir}"
    end
    flow do
      destination_prompt = para "File will be saved to:"
      @destination = para "#{$outputdir}", underline: "single"
    end 
  end

  flow do
    preview = button "Preview"
    preview.click do
      BufferCheck($sample_rate_choice)
      Soxcommand = 'rec -r ' + $sample_rate_choice + ' -b 32 -L -e signed-integer --buffer ' + $soxbuffer + ' -p remix ' + sox_channels
      FFmpegSTART = 'ffmpeg -channel_layout ' + ffmpeg_channels + ' -i - '
      FFmpegPreview = '-f wav -c:a ' + 'pcm_s16le' + ' -ar ' + '44100' + ' -'
      FFplaycommand = 'ffplay -window_title "AudioRecorder" -f lavfi ' + '"' + 'amovie=\'pipe\:0\'' + ',' + FILTER_CHAIN + '"' 
      ffmpegcommand = FFmpegSTART + FFmpegPreview
      command = Soxcommand + ' | ' + ffmpegcommand + ' | ' + FFplaycommand
      system(command)
    end

    record = button "Record"
    record.click do
      BufferCheck($sample_rate_choice)
      filename = ask("Please Enter File Name")
      @tempfileoutput = '"' + $outputdir + '/' + filename + '"'
      @fileoutput = $outputdir + '/' + filename + '.wav'
      if ! File.exist?(@fileoutput)
        Soxcommand = 'rec -r ' + $sample_rate_choice + ' -b 32 -L -e signed-integer --buffer ' + $soxbuffer + ' -p remix ' + sox_channels
        FFmpegSTART = 'ffmpeg -channel_layout ' + ffmpeg_channels + ' -i - '
        FFmpegRECORD = '-f wav -c:a ' + $codec_choice  + ' -ar ' + $sample_rate_choice + ' -metadata comment="" -y -rf64 auto ' + 'AUDIORECORDERTEMP.wav'
        FFmpegPreview = ' -f wav -c:a ' + 'pcm_s16le' + ' -ar ' + '44100' + ' -'
        FFplaycommand = 'ffplay -window_title "AudioRecorder" -f lavfi ' + '"' + 'amovie=\'pipe\:0\'' + ',' + FILTER_CHAIN + '"' 
        ffmpegcommand = FFmpegSTART + FFmpegRECORD + FFmpegPreview
        syscommand1 = Soxcommand + ' | ' + ffmpegcommand + ' | ' + FFplaycommand
        syscommand2 = 'ffmpeg -i ' + 'AUDIORECORDERTEMP.wav' + ' -lavfi showwavespic=split_channels=1:s=500x150:colors=blue -y AUDIORECORDERTEMP.png -c copy ' + "'" + @fileoutput + "'" + ' && rm ' + 'AUDIORECORDERTEMP.wav'
        system(syscommand1) && system(syscommand2)
        if $embedbext == 'true'
          EmbedBEXT(@fileoutput)
        end
        PostRecord(@fileoutput)
      else
        alert "A File named #{filename} already exists at that location!"
      end
    end

    button "Edit BWF Metadata" do
      window(title: "Edit BWF Metadata", width: 600, height: 500) do
        background aliceblue
        stack do
          para "Please Make Selections"
          para "Originator"
          originator_choice = edit_line text = $originator do
            $originator = originator_choice.text
          end
          para "Coding History"
          history_choice = edit_box text = $history do
            $history = history_choice.text
          end
          flow do
            bextswitch = check
            if $embedbext == 'true'
              bextswitch.checked = true
            elsif $embedbext =='false'
              bextswitch.checked = false
            end 
            para "Embed BFW Metadata?"
            bextswitch.click do
              if bextswitch.checked?
                $embedbext = 'true'
              else
                $embedbext = 'false'
              end
            end
          end
          button "Save Settings" do
            config['destination'] = $outputdir
            config['samplerate'] = $sample_rate_choice
            config['channels'] = sox_channels
            config['codec'] = $codec_choice
            config['orig'] = $originator
            config['hist'] = $history
            config['bext'] = $embedbext
            File.open(configuration_file, 'w') {|f| f.write config.to_yaml }
            close()
          end
          close = button "Cancel"
          close.click do
            close()
          end
        end
      end
    end

    button "Save Settings" do
      config['destination'] = $outputdir
      config['samplerate'] = $sample_rate_choice
      config['channels'] = sox_channels
      config['codec'] = $codec_choice
      config['orig'] = $originator
      config['hist'] = $history
      config['bext'] = $embedbext
      File.open(configuration_file, 'w') {|f| f.write config.to_yaml }
    end

    exit = button "Quit"
    exit.click do
        exit()
    end
  end
end

#Cascadia Now!
