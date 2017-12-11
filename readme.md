# Maven cleanup
* pomwithtransitive.rb from [Cleaning up unused depencencies](http://reallifejava.com/cleaning-up-unused-dependencies-in-maven-projects/)
    * this adds all artifact id from pom groups specifically
    * `pomwithtransitive.rb /path/to/root/pom.xml`
* remove-extra-dependencies.rb from [maven-cleanup](https://github.com/siivonen/maven-cleanup)
    * this removes unused dependencies at the highest level. Please test for runtime dependencies missing and add specifically
    * `./remove-extra-dependencies.rb /my_project/pom.xml 'mvn clean install -N'`