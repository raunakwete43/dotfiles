from libqtile.widget import base
import subprocess

class DataUsageWidget(base.ThreadPoolText):
    def __init__(self, text, **config):
        super().__init__(text, **config)
        self.add_defaults(base.ThreadPoolText.defaults)


    def poll(self):
	result = subprocess.run(["/home/manupro85/Downloads/scripts/data_used.sh"],capture_output=True,text=True,check=True,)
	return result.stdout.strip()
