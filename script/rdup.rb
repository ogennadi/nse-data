DIR = "../price/"
NEWDIR = "../uprice/"

def u(file)
  `uniq #{DIR}#{file} > #{NEWDIR}#{file}`
end

def us()
  Dir.new(DIR).drop(2).each do |file|
    u(file)
  end
end
