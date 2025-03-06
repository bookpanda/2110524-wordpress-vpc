```bash
# they're test ip/passwords, no harm done

mysql -h 13.215.250.114 -u root -p -P 3306
mysql -h ec2-13-215-250-114.ap-southeast-1.compute.amazonaws.com -u root -p -P 3306
mysql -h 10.0.3.100 -u username -p -P 3306
password
use wordpress
drop table wp_commentmeta,wp_comments,wp_links,wp_options,wp_postmeta,wp_posts,wp_term_relationships,wp_term_taxonomy,wp_termmeta,wp_terms,wp_usermeta, wp_users;

# check user_data progress on ec2
sudo tail -f /var/log/cloud-init-output.log

# wordpress ec2 can ssh to mariadb ec2 using ip of ein in app_db subnet
ssh -i "cloud-computing.pem" ubuntu@10.0.3.100

sudo mysql -u root
sudo mysql -u username -p 
password

# mark ec2 as tainted, will be recreated in apply (used for user_data changes)
terraform taint module.ec2.aws_instance.wordpress
terraform apply

# clean key
ssh-keygen -R 54.251.110.185
ssh-keygen -R 10.0.3.100

# check users
SELECT user, host FROM mysql.user;

DB_NAME=wordpress
DB_USER=username
DB_PASS=password
DB_HOST="10.0.3.100:3306"
DB_PREFIX=wp_
WP_URL="http://175.41.149.116"
WP_ADMIN_USER=root
WP_ADMIN_PASS=notverys3curepassword
WP_ADMIN_EMAIL=admin@example.com
WP_TITLE="Cloud"

BUCKET_NAME=wp-test-loam
AZ=ap-southeast-1
# see option
sudo -u www-data -- wp option get amazon_s3_options --allow-root


wp plugin install amazon-s3-and-cloudfront --activate
wp option update amazon_s3_options '{
  "bucket": "wp-test-loam",
  "region": "ap-southeast-1", 
  "use_ssl": "1",
  "cloudfront": "1"
}'
```

```php
define( 'AS3CF_SETTINGS', serialize( array(
    'provider' => 'aws',
    'use-server-roles' => true,
    'bucket' => 'wp-test-loam',
    'region' => 'ap-southeast-1',
    'copy-to-s3' => true,
    'enable-object-prefix' => true,
    'object-prefix' => 'wp-content/uploads/',
    'use-yearmonth-folders' => true,
    'object-versioning' => true,
    'delivery-provider' => 'storage',
    'serve-from-s3' => true,
    'enable-signed-urls' => false,
    'force-https' => false,
    'remove-local-file' => false,
) ) );
```

### SSH
```bash
ssh-keygen -t ed25519 -f ./test
ssh -i "~/.ssh/test" ubuntu@ec2-54-255-161-156.ap-southeast-1.compute.amazonaws.com
cat ~/.ssh/id_rsa | pbcopy
ssh -i test2 ubuntu@10.0.3.100
```
