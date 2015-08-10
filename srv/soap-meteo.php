<pre><?php
$pocasiClient = new SoapClient( 'http://support-apps.cro.cz/services/pocasi/wsdl' );
$params = array(
    'env' => array(
         'getParams' => array(
              'den' => '2015-03-04',
              'doba' => 'noc',
              'region' => '9'
          )
     )
);
$t = mktime(14, 0, 0, 5, 29, 2011);
set_time_limit(0);
$now = time();
while($t < $now) {
  $date = date('Y-m-d H:i:s', $t);
  echo $date;
  $data = $pocasiClient->getWeatherReviewRecords(['env' => ['getParams' =>['den' => $date]]]);
  $xml = $data['data'];
  $sd = substr($date, 0, 10);
  print_r("../data/raw/$sd.xml");
  file_put_contents("../data/raw/$sd.xml", $xml);
  $t += 86400;
}

