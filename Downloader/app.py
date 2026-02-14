import os
import sys
import webbrowser
from flask import Flask, render_template, request, send_file, after_this_request
import yt_dlp
import tempfile
import shutil
from threading import Timer

app = Flask(__name__)

#buscar cookies locales si existen
def get_cookie_file():
    if os.path.exists('cookies.txt'):
        return 'cookies.txt'
    return None

def get_temp_dir():
    return tempfile.mkdtemp()

def open_browser():
    webbrowser.open_new("http://127.0.0.1:5000")

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

@app.route('/guide')
def guide():
    return render_template('guide.html')

@app.route('/download', methods=['POST'])
def download():
    url = request.form.get('url')
    formato = request.form.get('format')
    
    if not url:
        return "Falta la URL", 400

    temp_dir = get_temp_dir()
    cookie_file = get_cookie_file()
    
    #configuración base
    ydl_opts = {
        'outtmpl': os.path.join(temp_dir, '%(title)s.%(ext)s'),
        'restrictfilenames': True,
        'noplaylist': True,
    }

    #cookies opcionales
    if cookie_file:
        ydl_opts['cookiefile'] = cookie_file
    
    #logica de formatos
    if formato == 'mp3':
        ydl_opts.update({
            'format': 'bestaudio/best',
            'postprocessors': [
                {'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3', 'preferredquality': '192'},
                {'key': 'FFmpegMetadata'},
            ],
        })
    elif formato == 'whatsapp':
        ydl_opts.update({
            'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4',
            'postprocessors': [{
                'key': 'FFmpegVideoConvertor',
                'preferedformat': 'mp4'
            }],
        })
    else: #MP4
        ydl_opts.update({
            'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
        })

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)
            
            if formato == 'mp3':
                base, _ = os.path.splitext(filename)
                filename = base + '.mp3'

        @after_this_request
        def remove_file(response):
            try:
                shutil.rmtree(temp_dir)
            except Exception as e:
                print(f"Error limpiando: {e}")
            return response

        return send_file(filename, as_attachment=True)

    except Exception as e:
        return f"Error: {str(e)}<br><br><a href='/'>Volver</a>", 500

if __name__ == '__main__':
    #abrir navegador automáticamente tras 1.5 segundos
    Timer(1.5, open_browser).start()
    app.run(host='0.0.0.0', port=5000, debug=False)