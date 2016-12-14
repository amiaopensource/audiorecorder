#!/usr/bin/env bash
#Cascadia Now!
config="$HOME/.$(basename "${0}").conf"
bwf_config="$HOME/.$(basename "${0}")_BWF.conf"
touch "${config}"
touch "${bwf_config}"
. "$config"
. "${bwf_config}"



OPTIND=1
while getopts "epm" opt ; do
    case "${opt}" in
        e) runtype="edit";;
        p) runtype="passthrough";;
        m) runtype="metadata";;
        *)
    esac
done

_lookup_devices(){
    OLDIFS="$IFS"
    device_list=("$(ffmpeg -hide_banner -f avfoundation -list_devices true -i "" -f null /dev/null 2>&1 | cut -d ' ' -f6- | sed -e                  '1,/AVFoundation audio devices:/d' | grep -v '^$'| tr '\n' ',' )")
    IFS=',' read -r -a DEVICES <<< "$device_list"
    IFS="$OLDIFS"
}
_lookup_sample_rate(){
    case "${1}" in
        "44.1 kHz")
            SAMPLE_RATE_NUMERIC="44100"
            ;;
        "48 kHz")
            SAMPLE_RATE_NUMERIC="48000"
            ;;
        "96 kHz")
            SAMPLE_RATE_NUMERIC="96000"
            ;;
    esac
}

_lookup_bit_depth(){
    case "${1}" in
        "16 bit")
            CODEC="pcm_s16le"
            ;;
        "24 bit")
            CODEC="pcm_s24le"
            ;;
    esac
}

_metadata_gui(){
    gui_conf="
    # Set transparency: 0 is transparent, 1 is opaque
    *.transparency=0.95
    # Set window title
    *.title = Edit Metadata Values
    # intro text
    intro.width = 300
    intro.type = text
    intro.text = Hello
    #Originator
    originator.type = textfield
    originator.label = Enter Originator
    originator.default = "${originator}"
    #Coding History
    coding_history.type = textbox
    coding_history.label = Enter Originator
    coding_history.default = "${coding_history}"
    cb.type = cancelbutton
    cb.label = Cancel
    "

    pashua_configfile=`/usr/bin/mktemp /tmp/pashua_XXXXXXXXX`
    echo "${gui_conf}" > "${pashua_configfile}"
    pashua_run
    rm "${pashua_configfile}"
}

_master_gui(){
    _lookup_devices    
    gui_conf="
    # Set transparency: 0 is transparent, 1 is opaque
    *.transparency=0.95
    # Set window title
    *.title = Welcome to Audio Recorder!
    # intro text
    intro.width = 300
    intro.type = text
    intro.text = Hello
    #Output Location
    output.type = openbrowser
    output.label = Output Location
    output.default = "${output}"
    #Capture Device
    device.type = popup
    device.label = Select Audio Capture Device
    device.option = ${DEVICES[0]}
    device.option = ${DEVICES[1]}
    device.option = ${DEVICES[2]}
    device.option = ${DEVICES[3]}
    device.default = "${device}"
    #Sample Rate
    sample_rate.type = radiobutton
    sample_rate.label = Select Sample Rate
    sample_rate.option = 44.1 kHz
    sample_rate.option = 48 kHz
    sample_rate.option = 96 kHz
    sample_rate.default = "${sample_rate}"
    #Bit Depth
    bit_depth.type = radiobutton
    bit_depth.label = Select Bit Depth
    bit_depth.option = 16 bit
    bit_depth.option = 24 bit
    bit_depth.default = "${bit_depth}"
    #Cancel Button
    cb.type = cancelbutton
    cb.label = Cancel
    "

    pashua_configfile=`/usr/bin/mktemp /tmp/pashua_XXXXXXXXX`
    echo "${gui_conf}" > "${pashua_configfile}"
    pashua_run
    rm "${pashua_configfile}"
}
pashua_run() {
    # Wrapper function for interfacing to Pashua. Written by Carsten
    # Bluem <carsten@bluem.net> in 10/2003, modified in 12/2003 (including
    # a code snippet contributed by Tor Sigurdsson), 08/2004 and 12/2004.
    # Write config file

    # Find Pashua binary. We do search both . and dirname "$0"
    # , as in a doubleclickable application, cwd is /
    # BTW, all these quotes below are necessary to handle paths
    # containing spaces.
    bundlepath="Pashua.app/Contents/MacOS/Pashua"
    mypath=$(dirname "${0}")
    for searchpath in "$mypath/Pashua" "$mypath/$bundlepath" "./$bundlepath" \
                      "/Applications/$bundlepath" "$HOME/Applications/$bundlepath"
    do
        if [ -f "$searchpath" -a -x "$searchpath" ] ; then
            pashuapath=$searchpath
            break
        fi
    done
    if [ ! "$pashuapath" ] ; then
        echo "Error: Pashua is not found."
                break 2
            fi
        encoding=""
        # Get result
        result=`"$pashuapath" $encoding $pashua_configfile | sed 's/ /;;;/g'`

        # Parse result
        for line in $result ; do
            key=`echo $line | sed 's/^\([^=]*\)=.*$/\1/'`
            value=`echo $line | sed 's/^[^=]*=\(.*\)$/\1/' | sed 's/;;;/ /g'`
            varname=$key
            varvalue="$value"
            eval $varname='$varvalue'
        done
} # pashua_run()

if [ "${runtype}" = "edit" ] ; then
_master_gui

{
    echo "output=\"${output}\""
    echo "device=\"${device}\""
    echo "sample_rate=\"${sample_rate}\""
    echo "bit_depth=\"${bit_depth}\""
} > "${config}"
fi

if [ "${runtype}" = "metadata" ] ; then
_metadata_gui

{
    echo "originator=\"${originator}\""
    echo "coding_history=\"${coding_history}\""
} > "${bwf_config}"
exit 0
fi

if [ -n ${DEVICE_NUMBER} ] ; then
    _lookup_sample_rate "${sample_rate}"
else 
    echo "No Sample Rate Specified.  Setting to 96kH."
    SAMPLE_RATE_NUMERIC="96000"
fi
if [ -n "${bit_depth}" ] ; then
    _lookup_bit_depth  "${bit_depth}"
else 
    echo "No Bit Depth Specified.  Setting to 24."
    CODEC="pcm_s24le"
fi
if [ -n "${device}" ] ; then
    DEVICE_NUMBER=$(echo "${device}" | cut -c 2)
else 
    echo "No Device Specified.  Attempting to Guess Device."
    DEVICE_NUMBER="0"
fi
if [ -z "${output}" ] ; then
    echo "No Output Location Specified.  Setting Output to Desktop"
    output="~/Desktop"
fi


FILTER_CHAIN="asplit=6[out1][a][b][c][d][e],\
[e]showvolume=w=700:c=0xff0000:r=30[e1],\
[a]showfreqs=mode=bar:cmode=separate:size=300x300:colors=magenta|yellow[a1],\
[a1]drawbox=12:0:3:300:white@0.2[a2],[a2]drawbox=66:0:3:300:white@0.2[a3],[a3]drawbox=135:0:3:300:white@0.2[a4],[a4]drawbox=202:0:3:300:white@0.2[a5],[a5]drawbox=271:0:3:300:white@0.2[aa],\
[b]avectorscope=s=300x300:r=30:zoom=5[b1],\
[b1]drawgrid=x=150:y=150:c=white@0.3[bb],\
[c]showspectrum=s=400x600:mode=combined:color=rainbow:scale=lin:saturation=4[cc],\
[d]astats=metadata=1:reset=1,adrawgraph=lavfi.astats.Overall.Peak_level:max=0:min=-30.0:size=700x256:bg=Black[dd],\
[dd]drawbox=0:0:700:42:hotpink@0.2:t=42[ddd],\
[aa][bb]vstack[aabb],[aabb][cc]hstack[aabbcc],[aabbcc][ddd]vstack[aabbccdd],[e1][aabbccdd]vstack[z],\
[z]drawtext=fontfile=/Library/Fonts/Andale Mono.ttf: text='%{pts \\: hms}':x=460: y=50:fontcolor=white:fontsize=30:box=1:boxcolor=0x00000000@1[fps],[fps]fps=fps=30[out0]"


if [ "${runtype}" = "passthrough" ] ; then
    ffmpeg -f avfoundation -i "none:"${DEVICE_NUMBER}"" -f wav -c:a pcm_s16le -ar 44100 - |\
    ffplay -window_title "Skookum Player" -f lavfi \
    "amovie='pipe\:0',${FILTER_CHAIN}"
    exit
fi

echo "Please Input Item ID"
read ITEM_ID
mkfifo PIPE2REC
ffmpeg -f avfoundation -i "none:"${DEVICE_NUMBER}"" -f wav -c:a "${CODEC}" -ar "${SAMPLE_RATE_NUMERIC}" -y PIPE2REC -f wav -c:a pcm_s16le -ar 44100 - |\
ffplay -window_title "Skookum Player" -f lavfi \
"amovie='pipe\:0',${FILTER_CHAIN}" | ffmpeg -i PIPE2REC -c copy -rf64 auto "${output}"/"${ITEM_ID}".wav

# Check length of Originator Reference against 32 character limit (pulled from file name)
if
	(("${#ITEM_ID}" > 32));
then
	orig_ref="See description for Identifiers"
else
    orig_ref="${ITEM_ID}"
fi

bwfmetaedit --reject-overwrite --Description="${ITEM_ID}".wav --Originator="${originator}" --OriginatorReference="${orig_ref}" --History="${coding_history}" --IARL="${originator}" --MD5-Embed --OriginationDate=$(date "+%Y-%m-%d") --OriginationTime=$(date "+%H:%M:%S") "${output}"/"${ITEM_ID}".wav
