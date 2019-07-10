#standardSQL
SELECT
  CASE 
   WHEN platform = 'seravo' THEN 'Seravo'
   WHEN platform = 'automattic.com/jobs' THEN 'Automattic' 
   WHEN platform = 'x-ah-environment' THEN 'Acquia'
   WHEN platform = 'x-pantheon-styx-hostname' THEN 'Pantheon'
   WHEN platform = 'wpe-backend' THEN 'WP Engine'
   WHEN platform = 'x-kinsta-cache' THEN 'Kinsta'
   WHEN platform = 'hubspot' THEN 'HubSpot'
   WHEN platform = '192fc2e7e50945beb8231a492d6a8024' THEN 'Siteground'
   ELSE NULL
  END AS platform,
  client,
  COUNT(DISTINCT origin) AS n,
  SUM(IF(ttfb.start < 200, ttfb.density, 0)) / SUM(ttfb.density) AS fast,
  SUM(IF(ttfb.start >= 200 AND ttfb.start < 1000, ttfb.density, 0)) / SUM(ttfb.density) AS avg,
  SUM(IF(ttfb.start >= 1000, ttfb.density, 0)) / SUM(ttfb.density) AS slow
FROM
  `chrome-ux-report.all.201906`,
  UNNEST(experimental.time_to_first_byte.histogram.bin) AS ttfb
JOIN
  (SELECT _TABLE_SUFFIX AS client, url, REGEXP_EXTRACT(LOWER(CONCAT(respOtherHeaders, resp_x_powered_by)), '(seravo|x-kinsta-cache|automattic.com/jobs|x-ah-environment|x-pantheon-styx-hostname|wpe-backend|hubspot|192fc2e7e50945beb8231a492d6a8024)') AS platform FROM `httparchive.summary_requests.2019_05_01_*`)
ON
  client = IF(form_factor.name = 'desktop', 'desktop', 'mobile') AND
  CONCAT(origin, '/') = url
WHERE
  platform IS NOT NULL
GROUP BY
  platform,
  client
ORDER BY
  n DESC