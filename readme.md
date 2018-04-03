# 翻译 Fanyi

### Translate stuff.
Fanyi is a simple translation script that employs the free [Microsoft Translator API](http://www.microsoft.com/en-us/translator/getstarted.aspx) in order to translate a text file, line by line, into a different language. The script also allows for a custom list of excluded words or phrases such as branded terms like "Acme Company" and HTML entities.

### Usage Synopsis
Single file conversion:
```
perl fanyi.pl input_filename.txt output_filename.txt
```

Multiple file conversion recursively through a directory tree:
```
find /path/to/target_directory -type f -exec sh -c '
perl /path/to/fanyi.pl $0 $0.new &&
mv $0.new $0
' {} \;
```

### Configuration
The script expects two configuration files:
* `config.yml` contains your Microsoft Translator API credentials. If you need to setup credentials, follow Microsoft's instructions [here](http://www.microsoft.com/en-us/translator/getstarted.aspx). A free API account allows for up to two million translated characters per month. The config file also contains the source and destination language codes you want to use for your translation, in the [notation format expressed here](https://msdn.microsoft.com/en-us/library/hh456380.aspx).
* `exclude.list` contains a list of terms (in Regex format) you don't want to translate.

### Translation and Exclusions
Translations are done line-by-line. An entire line is translated as a single entity, excluding any words and phrases specified in `exclude.list`. If there are phrases before and after an excluded term, they are translated independently. So, if "Acme" is an excluded term, then the phrase "View all of the Acme products in your subscription" will be translated as the separate phrases "View all of the" and "products in your subscription," then reassembled into, for example, "查看所有Acme产品在你的订阅."
