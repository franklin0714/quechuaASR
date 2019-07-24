import pyaudio
import wave
import numpy as np
import scipy.io.wavfile
import os

class Audio_grabado:
	def __init__(self,*args):
		self.FORMAT = pyaudio.paInt16
		self.CHANNELS = 1
		self.RATE = 16000
		self.CHUNK = 1024
		self.RECORD_SECONDS = 6
		self.WAVE_OUTPUT_FILENAME = "/home/franklin/Escritorio/kaldi/egs/quechua/quechua_audio/test/21/01/21-01-0000.wav"
		#self.ARCHIVO = "/home/franklin/Escritorio/kaldi/egs/quechua/exp/mono/decode/log/decode.1.log"
		self.ARCHIVO = "/home/franklin/Escritorio/kaldi/egs/quechua/experiment/nnet2/nnet2_simple/decode/log/decode.1.log"
		self.THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
		self.my_file = os.path.join(self.THIS_FOLDER, 'prueba.wav')
		self.Texto=""
		print(self.THIS_FOLDER)
	 
	def grabar(self):
		audio = pyaudio.PyAudio()
		# start Recording
		stream = audio.open(format=self.FORMAT, channels=self.CHANNELS,
				rate=self.RATE, input=True,
				frames_per_buffer=self.CHUNK)
		print "recording..."
		frames = []
		 
		for i in range(0, int(self.RATE / self.CHUNK * self.RECORD_SECONDS)):
		    data = stream.read(self.CHUNK)
		    frames.append(data)
		print "finished recording"
		 
		 
		# stop Recording
		stream.stop_stream()
		stream.close()
		audio.terminate()
		
 		#scipy.io.wavfile.write(self.WAVE_OUTPUT_FILENAME,self.RATE,frames)
		waveFile = wave.open(self.WAVE_OUTPUT_FILENAME, 'wb')
		waveFile.setnchannels(self.CHANNELS)
		waveFile.setsampwidth(audio.get_sample_size(self.FORMAT))
		waveFile.setframerate(self.RATE)
		waveFile.writeframes(b''.join(frames))
		waveFile.close()
	def obtener_texto(self):
		ruta='/home/franklin/Escritorio/kaldi/egs/quechua'
		os.chdir(ruta)
		os.system('./decode_test.sh')
		archivo=open(self.ARCHIVO,"r")
		for linea in archivo:
			if linea[0:10]=='21-01-0000':
				self.Texto=linea[10:]
		return self.Texto
		archivo.close()
		
