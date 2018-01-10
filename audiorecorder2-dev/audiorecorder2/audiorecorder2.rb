require 'yaml'

# Recording Variables
FILTER_CHAIN = "asplit=6[out1][a][b][c][d][e],\
[e]showvolume=w=700:c=0xff0000:r=30[e1],\
[a]showfreqs=mode=bar:cmode=separate:size=300x300:colors=magenta|yellow[a1],\
[a1]drawbox=12:0:3:300:white@0.2[a2],[a2]drawbox=66:0:3:300:white@0.2[a3],[a3]drawbox=135:0:3:300:white@0.2[a4],[a4]drawbox=202:0:3:300:white@0.2[a5],[a5]drawbox=271:0:3:300:white@0.2[aa],\
[b]avectorscope=s=300x300:r=30:zoom=5[b1],\
[b1]drawgrid=x=150:y=150:c=white@0.3[bb],\
[c]showspectrum=s=400x600:slide=scroll:mode=combined:color=rainbow:scale=lin:saturation=4[cc],\
[d]astats=metadata=1:reset=1,adrawgraph=lavfi.astats.Overall.Peak_level:max=0:min=-30.0:size=700x256:bg=Black[dd],\
[dd]drawbox=0:0:700:42:hotpink@0.2:t=42[ddd],\
[aa][bb]vstack[aabb],[aabb][cc]hstack[aabbcc],[aabbcc][ddd]vstack[aabbccdd],[e1][aabbccdd]vstack[out0]"

sox_channels = '1 2'
ffmpeg_channels = 'stereo'
codec_choice = 'pcm_s24le'
soxbuffer = '50000'
sample_rate_choice = '96000'

if RUBY_PLATFORM.include?('linux')
  Drawfontpath = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'
end

configuration_file = File.expand_path('~/.audiorecorder2.conf')
if ! File.exist?(configuration_file)
  config_options = "destination:\nsamplerate:\nchannels:\ncodec:"
  File.write(configuration_file, config_options)
end
config = YAML::load_file(configuration_file)
outputdir = config['destination']
sample_rate_choice = config['samplerate']
sox_channels = config['channels']
codec_choice = config['codec']

# GUI App
Shoes.app(title: "Welcome to AudioRecorder", width: 600, height: 500) do
  style Shoes::Para, font: "Helvetica"
  background aliceblue
  @logo = image("Resources/audiorecorder_small.png", left: 160)

  flow margin: 10 do
    para "Select Channel(s)"
    channels = list_box items: ["1", "2", "1 2"],
    width: 100, choose: sox_channels do |list|
      sox_channels = list.text
      if sox_channels == "1 2"
        ffmpeg_channels = 'stereo'
      else
        ffmpeg_channels = 'mono'
      end
    end

    para "Sample Rate"
    samplerate = list_box items: ["44100", "48000", "96000"],
    width: 100, choose: sample_rate_choice do |list|
      sample_rate_choice = list.text
    end

    para "Codec"
    samplerate = list_box items: ["pcm_s16le", "pcm_s24le"],
    width: 100, choose: codec_choice do |list|
      codec_choice = list.text
    end
  end

  stack margin: 10 do
    button "Choose Output Directory" do
      outputdir = ask_open_folder
      @destination.replace "#{outputdir}"
    end
    flow do
      destination_prompt = para "File will be saved to:"
      @destination = para "#{outputdir}", underline: "single"
    end 
  end

  flow do
    preview = button "Preview"
    preview.click do
      Soxcommand = 'rec -r ' + sample_rate_choice + ' -b 32 -L -e signed-integer --buffer ' + soxbuffer + ' -p remix ' + sox_channels
      FFmpegSTART = 'ffmpeg -channel_layout ' + ffmpeg_channels + ' -i - '
      FFmpegPreview = '-f wav -c:a ' + 'pcm_s16le' + ' -ar ' + '44100' + ' -'
      FFplaycommand = 'ffplay -window_title "AudioRecorder" -f lavfi ' + '"' + 'amovie=\'pipe\:0\'' + ',' + FILTER_CHAIN + '"' 
      ffmpegcommand = FFmpegSTART + FFmpegPreview
      command = Soxcommand + ' | ' + ffmpegcommand + ' | ' + FFplaycommand
      system(command)
    end

    record = button "Record"
    record.click do
      filename = ask("Please Enter File Name")
      @fileoutput = '"' + outputdir + '/' + filename + '"'
      Soxcommand = 'rec -r ' + sample_rate_choice + ' -b 32 -L -e signed-integer --buffer ' + soxbuffer + ' -p remix ' + sox_channels
      FFmpegSTART = 'ffmpeg -channel_layout ' + ffmpeg_channels + ' -i - '
      FFmpegRECORD = '-f wav -c:a ' + codec_choice  + ' -ar ' + sample_rate_choice + ' -metadata comment="" -y -rf64 auto ' + @fileoutput
      FFmpegPreview = ' -f wav -c:a ' + 'pcm_s16le' + ' -ar ' + '44100' + ' -'
      FFplaycommand = 'ffplay -window_title "AudioRecorder" -f lavfi ' + '"' + 'amovie=\'pipe\:0\'' + ',' + FILTER_CHAIN + '"' 
      ffmpegcommand = FFmpegSTART + FFmpegRECORD + FFmpegPreview
      command = Soxcommand + ' | ' + ffmpegcommand + ' | ' + FFplaycommand
      system(command)
    end

    button "Edit BWF Metadata" do
      window(title: "A new window") do
        para "Please Make Selections"
      end
    end

    button "Save Settings" do
      config['destination'] = outputdir
      config['samplerate'] = sample_rate_choice
      config['channels'] = sox_channels
      config['codec'] = codec_choice
      File.open(configuration_file, 'w') {|f| f.write config.to_yaml }
    end

    exit = button "Quit"
    exit.click do
        exit()
    end
  end
end

#Cascadia Now!
