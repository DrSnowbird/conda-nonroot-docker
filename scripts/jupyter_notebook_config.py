import os
from IPython.lib import passwd

# Set options for certfile, ip, password, and toggle off
# browser auto-opening
#c.NotebookApp.certfile = u'/absolute/path/to/your/certificate/mycert.pem'
#c.NotebookApp.keyfile = u'/absolute/path/to/your/certificate/mykey.key'
# Set ip to '*' to bind on all interfaces (ips) for the public server

c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = int(os.getenv('PORT', 8888))
c.NotebookApp.open_browser = True
c.MultiKernelManager.default_kernel_name = 'python3'

# sets a password if PASSWORD is set in the environment
#if 'PASSWORD' in os.environ:
#  c.NotebookApp.password = passwd(os.environ['PASSWORD'])
#  del os.environ['PASSWORD']

# sets a password if PASSWORD is set in the environment
if not 'PASSWORD' in os.environ or os.environ['PASSWORD'] is None:
    os.environ['PASSWORD']="ChangeMe!"
    
if 'PASSWORD' in os.environ:
    print("===>> Passowrd=" + os.environ['PASSWORD'])
    c.NotebookApp.password = passwd(os.environ['PASSWORD'])
    print("Password file at " + os.environ['JUPYTER_CONF_DIR'] + "/jupyter_password.txt")
    fp = open(os.environ['JUPYTER_CONF_DIR']+"/jupyter_password.txt", "w")
    fp.write(os.environ['PASSWORD'])
    fp.close()
    #del os.environ['PASSWORD']

