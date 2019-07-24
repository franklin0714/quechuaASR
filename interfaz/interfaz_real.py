#importando libreria para desarrollo de interfaz
from Tkinter import *
from PIL import Image, ImageTk
from Audio_grabado import *

#funciones
class interfaz_real:
	def __init__(self,*args):
	   self.texto="aver"

	def Enviar():
	   audio1=Audio_grabado()
	   grabado=audio1.grabar()

	def Obtener():
	   audio2=Audio_grabado()
	   texto=audio2.obtener_texto()
	   Texto=Label(text=texto,font=("verdana",10)).place(x=250,y=413)

	# creando una ventana nueva
	ventana=Frame(height=400,width=600)
	ventana.pack(padx=20,pady=20)
	Texto=Label(text="Conversor de voz a texto en Quechua Cusco-Collao",font=("verdana",15)).place(x=5,y=5)
	load = Image.open("audio_img.jpg")
	render = ImageTk.PhotoImage(load)
	Imagen_label=Label(image=render).place(x=0,y=50)
	#img = ImageTk.PhotoImage(Image.open("audio_img.jpg"))
	#panel = Label(ventana, image = img)
	#panel.pack(side = "bottom", fill = "both", expand = "yes")
	#img=PhotoImagen(file="audio_img.jpg")
	boton_grabar=Button(ventana,command=Enviar,text="Empesar Grabacion",font=("verdana",13),background="blue").place(x=0,y=360)
	boton_reconocer=Button(ventana,command=Obtener,text="Obtener Texto",font=("verdana",13),background="red").place(x=200,y=360)
	Texto=Label(text="Oracion reconocida:",font=("verdana",15)).place(x=20,y=410)
	ventana.mainloop()#fin de ventana
