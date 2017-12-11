require 'rexml/document'

if ARGV.size != 1  then
 puts("Usage: #{$0} /path/to/root/pom.xml")
 exit 1
end
puts "This script will add all effective dependencies of #{ARGV[0]} to the pom."

def replace_dependencies(pom, dependencies)
 originalContent = File.read(File.new(pom))
 content = originalContent

 puts originalContent
 if originalContent.include? "dependencyManagement"
   puts "has dependencyManagement section"

   if content =~ /<\/dependencyManagement>.*<dependencies>.*?<\/dependencies>/m
     puts "matches dependencyManagement first #{pom}"
     content = content.sub(/<(.*(dependencies)*.*<\/dependencyManagement>.*)<dependencies>.*?<\/dependencies>/m, '\1<dependencies>' + dependencies + "</dependencies>")
   elsif content =~ /<dependencies>.*?<\/dependencies>$\s+<\/dependencyManagement>/m
     puts "matches dependencyManagement last #{pom}"
     content = content.sub(/<dependencies>.*?<\/dependencies>/m, "<dependencies>" + dependencies + "</dependencies>")
   end
 else
   content = content.sub(/<dependencies>.*?<\/dependencies>/m, "<dependencies>" + dependencies + "</dependencies>")
 end

 File.open(pom, 'w') { |f| f.write(content) }
 puts "updated dependencies for pom #{pom}"
end

def generate_dependencies(pom)
 system("cd #{File.dirname(pom)} && mvn dependency:list -Dsort=true -DoutputFile=deps.txt -Dsilent=true > /dev/null 2> /dev/null")
 depsFile = File.dirname(pom) + "/deps.txt"
 dependencies = ""
 File.open(depsFile, "r") do |depsFileContents|
   depsFileContents.each_line do |line|
     if (!line.include? "The following") && (!line.chomp.empty?) && (!line.include? "none")
       parts = line.split(':')
       #puts line
       dependencies += %(
       <dependency>
         <groupId>#{parts[0].lstrip}</groupId>
         <artifactId>#{parts[1]}</artifactId>
         <version>#{parts[3]}</version>
         <scope>#{parts[4].chomp}</scope>
       </dependency>
)
     end
   end
 end
 #puts dependencies
 replace_dependencies(pom, dependencies)
 #File.delete(depsFile)
end

def generate_poms_and_dependencies(pom)
 dir = File.dirname(pom)
 generate_dependencies(pom)
 doc = REXML::Document.new(File.new(pom))
 REXML::XPath.match(doc, "//module").each do | mod |
   generate_poms_and_dependencies(dir + "/" +mod.text + "/pom.xml")
 end
end

generate_poms_and_dependencies(ARGV[0])
puts "All transitive dependencies have been added to the poms"