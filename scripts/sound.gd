extends Node
var voices={}
func _ready():
 var frequencies={"fire":130,"reload":320,"footstep":65,"detect":740,"attack":110,"pickup":880,"door":90,"damage":55,"secret":1200,"elevator":440,"ambient":48,"alarm":460,"music":110}
 for key in frequencies:
  var audio=AudioStreamPlayer.new()
  audio.name=key.capitalize()
  var override_path="res://assets/audio/"+key+".wav"
  audio.stream=load(override_path) if ResourceLoader.exists(override_path) else tone(frequencies[key],0.16 if key!="ambient" else 2.0,key=="ambient")
  audio.volume_db=-23 if key in ["ambient","music","alarm"] else -14
  add_child(audio)
  voices[key]=audio
 voices.ambient.play()
func tone(hz: float, seconds: float, looped: bool) -> AudioStreamWAV:
 var wav=AudioStreamWAV.new()
 wav.format=AudioStreamWAV.FORMAT_16_BITS
 wav.mix_rate=22050
 var bytes=PackedByteArray()
 var count=int(seconds*22050)
 bytes.resize(count*2)
 for i in count:
  var t=float(i)/22050.0
  var envelope=0.2 if looped else pow(1.0-float(i)/count,2.0)*0.55
  var value=int(sin(TAU*hz*t+sin(t*hz*0.2))*envelope*32767)
  bytes.encode_s16(i*2,value)
 wav.data=bytes
 if looped:
  wav.loop_mode=AudioStreamWAV.LOOP_FORWARD
  wav.loop_end=count
 return wav
func play(key: String):
 if voices.has(key): voices[key].play()
func _exit_tree():
 for audio in voices.values():
  audio.stop()
  audio.stream=null
 voices.clear()
