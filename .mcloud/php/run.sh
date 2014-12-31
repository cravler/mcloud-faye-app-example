#!/bin/bash

echo "Waiting while mysql starts"
while ! echo exit | nc -z mysql 3306; do
    echo ".";
    sleep 3;
done

if [ ! -d /var/www/sf ]; then

    composer create-project --no-interaction symfony/framework-standard-edition /var/www/sf/ "2.5.*"
    chmod +x /var/www/sf/app/console
    cp -R /var/www/.mcloud/php/sf/* /var/www/sf
    /var/www/sf/app/console doctrine:database:create

    # Install faye-app bundle
    /var/www/sf/app/console generate:bundle --namespace=Cravler/FayeAppBundle --no-interaction --dir=/var/www/sf/src
    composer require cravler/faye-app-bundle:dev-master --working-dir=/var/www/sf/
    rm -rf /var/www/sf/src/Cravler
    /var/www/sf/app/console assets:install sf/web/

    echo '' >> /var/www/sf/app/config/config.yml
    echo 'cravler_faye_app:' >> /var/www/sf/app/config/config.yml
    echo '    example: true' >> /var/www/sf/app/config/config.yml
    echo '    use_request_uri: true' >> /var/www/sf/app/config/config.yml
    echo '    user_provider: false #security.user.provider.concrete.[provider_name]' >> /var/www/sf/app/config/config.yml
    echo '    secret: "%secret%"' >> /var/www/sf/app/config/config.yml
    echo '    app:' >> /var/www/sf/app/config/config.yml
    echo '        host: nginx' >> /var/www/sf/app/config/config.yml
    echo '        port: 80' >> /var/www/sf/app/config/config.yml

    echo '' >> /var/www/sf/app/config/routing.yml
    echo 'cravler_faye_app:' >> /var/www/sf/app/config/routing.yml
    echo '    resource: "@CravlerFayeAppBundle/Resources/config/routing.yml"' >> /var/www/sf/app/config/routing.yml

    echo '' >> /var/www/sf/app/config/routing.yml
    echo 'root:' >> /var/www/sf/app/config/routing.yml
    echo '    path: /' >> /var/www/sf/app/config/routing.yml
    echo '    defaults:' >> /var/www/sf/app/config/routing.yml
    echo '        _controller: FrameworkBundle:Redirect:urlRedirect' >> /var/www/sf/app/config/routing.yml
    echo '        path: /faye-app/example' >> /var/www/sf/app/config/routing.yml
    echo '        permanent: true' >> /var/www/sf/app/config/routing.yml

else

    composer install --no-interaction --working-dir=/var/www/sf/

fi

@me ready in 3s
php5-fpm -R