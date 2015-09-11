#KSEA
file_stat = os.path.exists('KSEA.xml')
if file_stat:
    page = urllib2.urlopen('http://www.wrh.noaa.gov/mesowest/getobextXml.php?sid=KSEA')
else:
    page = urllib2.urlopen('http://www.wrh.noaa.gov/mesowest/getobextXml.php?sid=KSEA&num=500')
