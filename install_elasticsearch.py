import subprocess
import os
import urllib2
import zipfile
import sys

here = os.path.dirname(os.path.abspath(__file__))
tmp_dir = '/tmp'
elasticsearch_dir = '/elasticsearch'

def setup_elasticsearch():
	"""
	Installs Elasticsearch into the package directory and
	adds default settings for running in a test environment

	Change these settings in production

	"""
	port=9200
	if not os.path.exists(elasticsearch_dir):
		os.makedirs(elasticsearch_dir)

	url = get_elasticsearch_download_url()
	file_name = url.split('/')[-1]

	download_elasticsearch(tmp_dir)
	unzip_file(os.path.join(tmp_dir, file_name), tmp_dir)
	
	file_name_wo_extention = file_name[:-4]
	unzip_location = os.path.join(tmp_dir, file_name_wo_extention)
	# Move to folder without version in name, so we can easilly find it back
	os.rename(unzip_location, elasticsearch_dir)
	bin_dir = os.path.join(elasticsearch_dir, 'bin')
	
	es_config_directory = os.path.join(elasticsearch_dir, 'config')
	try:
		os.rename(os.path.join(es_config_directory, 'elasticsearch.yml'), os.path.join(es_config_directory, 'elasticsearch.yml.orig'))
	except: pass

	with open(os.path.join(es_config_directory, 'elasticsearch.yml'), 'w') as f:
		f.write('# ----------------- FOR TESTING ONLY -----------------')
		f.write('\n# - THESE SETTINGS SHOULD BE REVIEWED FOR PRODUCTION -')
		f.write('\nnode.max_local_storage_nodes: 1')
		f.write('\nnode.local: true')
		f.write('\nindex.number_of_shards: 1')
		f.write('\nindex.number_of_replicas: 0')
		f.write('\nhttp.port: %s' % port)
		f.write('\ndiscovery.zen.ping.multicast.enabled: false')
		f.write('\ndiscovery.zen.ping.unicast.hosts: ["localhost"]')
		f.write('\ncluster.routing.allocation.disk.threshold_enabled: false')

	# install HEAD plugin
	if sys.platform == 'win32':
		os.system("call %s --install mobz/elasticsearch-head" % (os.path.join(bin_dir, 'plugin.bat')))
	else:
		os.chdir(bin_dir)
		os.system("chmod u+x plugin")
		os.system("./plugin -install mobz/elasticsearch-head")
		os.system("chmod u+x elasticsearch")


def get_elasticsearch_download_url():
    with open("requirements.txt", "r") as f:
        for line in f:
            if line.startswith('# https://'):
                return line.replace('# ', '').strip()
    raise Exception("""\n
------------------------------------------------------------------------------------------------------
    ERROR: There was an error getting the url for Elastic search from the requirements.txt file
    Make sure the requirements.txt file contains a line similar to the following line,\nincluding the pound symbol (#) but not the double quotes (") and where the x.x.x represent the version number:
        "# https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-x.x.x.zip"
----------------------------------------------------------------------------------------------------\n""") 

def download_elasticsearch(install_dir):
    url = get_elasticsearch_download_url()
    file_name = url.split('/')[-1]
    if not os.path.isfile(os.path.join(install_dir, file_name)):
        download_file(url, os.path.join(install_dir, file_name))

def download_file(url, file_name):
    u = urllib2.urlopen(url)
    f = open(file_name, 'wb')
    meta = u.info()
    file_size = int(meta.getheaders("Content-Length")[0])
    print "Downloading: %s Bytes: %s" % (file_name, file_size)

    file_size_dl = 0
    block_sz = 8192
    while True:
        buffer = u.read(block_sz)
        if not buffer:
            break

        file_size_dl += len(buffer)
        f.write(buffer)
        status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
        status = status + chr(8) * (len(status) + 1)
        print status,

    f.close()

def unzip_file(file_name, unzip_location):
    with zipfile.ZipFile(file_name, 'r') as myzip:
        print 'unzipping %s to: %s' % (file_name, unzip_location)
        myzip.extractall(unzip_location)

if __name__ == "__main__":
    setup_elasticsearch()