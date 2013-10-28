#mt: minimal template

A simple ruby script to manage config files.

The config file has two sections namely content and config separated by a delimiter (`__CONFIG__`) more like ruby `__END__`. The content section could have simple template varibles of the the sytle %VARNAME%, for which the values are provided on the config section.

The config section has a env key which manages how many environments the files need to be generated for. The vars property on the section has the values of the property for different environments.

__Usage__:

>chmod +x ./process.rb

>./process.rb app.xml.trb

See: [app.xml.trb](app.xml.trb) for sample config file

__Output__:
```
<!-- updated by sraguram on Sun Oct 27 23:22:33 +0000 2013 -->
<appSettings>
  <app name="rabbit.host" value="rabbitmq.local" />
  <app name="service.endpoint" value="http://host.dev" />
</appSettings>
```
