#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rexml/document"
require "uri"

ROOT = Pathname.new(__dir__).parent.expand_path
DOCK_DIR = ROOT.join("obs-bible-plugin-dock")
BIBLES_DIR = DOCK_DIR.join("bibles")
OPENLP_DIR = ROOT.join("source-bibles", "openlp-xmm")
SQLITE_DIR = ROOT.join("source-bibles", "sqlite")

ABBREVIATIONS = {
  "Biblia Internacional Standard Version" => "BISV",
  "Biblia Jerusalen" => "BJ",
  "Biblia Latinoamericana 95" => "BLA95",
  "Biblia Latinoamericana de Hoy" => "BLH",
  "Biblia Lenguaje Sencillo" => "BLS",
  "Dios Habla Hoy" => "DHH",
  "Easy To Read Version" => "ERV",
  "King James 2000" => "KJ2000",
  "La Biblia de Las Americas" => "LBLA",
  "Las Sagradas Escrituras" => "LSE",
  "Modern King James Version" => "MKJV",
  "Nueva Biblia Latinoamericana de Hoy" => "NBLH",
  "Nueva Biblia de Jerusalen" => "NBJ",
  "Nueva Biblia de los Hispanos" => "NBDLH",
  "Palabra de Dios para Todos" => "PDT"
}.freeze

SKIP_OPENLP = [
  "NVI",
  "Nueva Traduccion Viviente",
  "Reina-Valera 1960",
  "Traduccion en Lenguaje Actual"
].freeze

def clean_text(text)
  text.to_s.gsub(/[[:space:]]+/, " ").strip
end

def abbreviation_for(name)
  return ABBREVIATIONS[name] if ABBREVIATIONS.key?(name)

  words = name.scan(/[[:alnum:]]+/)
  abbreviation = words.map { |word| word[0] }.join.upcase
  abbreviation.empty? ? "BIBLE" : abbreviation[0, 10]
end

def verse_hash(verse)
  Digest::SHA256.hexdigest(JSON.generate(verse))
end

def finish_payload(payload)
  payload["sha256"] = Digest::SHA256.hexdigest(JSON.generate(payload))
  "ObsBiblePlugin.importBible(#{JSON.generate(payload)});"
end

def build_from_openlp(path)
  name = path.basename(".xmm").to_s
  xml = path.read.delete_prefix("\uFEFF")
  doc = REXML::Document.new(xml)
  books = []
  scriptures = []
  verse_id = 1

  doc.root.each_element("b") do |book_element|
    book_id = books.length + 1
    books << { "id" => book_id, "name" => book_element.attributes["n"].to_s }

    book_element.each_element("c") do |chapter_element|
      chapter = chapter_element.attributes["n"].to_i

      chapter_element.each_element("v") do |verse_element|
        verse = {
          "id" => verse_id,
          "bookId" => book_id,
          "chapter" => chapter,
          "verse" => verse_element.attributes["n"].to_i,
          "text" => clean_text(verse_element.text)
        }
        verse["hash"] = verse_hash(verse)
        scriptures << verse
        verse_id += 1
      end
    end
  end

  {
    "name" => name,
    "abbreviation" => abbreviation_for(name),
    "copyright" => "Converted from supplied OpenLP XMM file.",
    "books" => books,
    "scriptures" => scriptures
  }
end

def sqlite_json(path, sql)
  stdout, status = Open3.capture2("sqlite3", "-json", path.to_s, sql)
  raise "sqlite3 failed for #{path}" unless status.success?

  JSON.parse(stdout)
end

def sqlite_metadata(path)
  sqlite_json(path, "select key, value from metadata order by key;").to_h do |row|
    [row.fetch("key"), row["value"]]
  end
end

def build_from_sqlite(path)
  metadata = sqlite_metadata(path)
  books = sqlite_json(path, "select id, name from book order by id;").map do |row|
    { "id" => row.fetch("id"), "name" => row.fetch("name") }
  end
  scriptures = sqlite_json(path, <<~SQL).map do |row|
    select id, book_id as bookId, chapter, verse, text
    from verse
    order by id;
  SQL
    verse = {
      "id" => row.fetch("id"),
      "bookId" => row.fetch("bookId"),
      "chapter" => row.fetch("chapter"),
      "verse" => row.fetch("verse"),
      "text" => clean_text(row.fetch("text"))
    }
    verse["hash"] = verse_hash(verse)
    verse
  end

  {
    "name" => metadata.fetch("name", path.basename(".sqlite").to_s),
    "abbreviation" => abbreviation_for(metadata.fetch("name", path.basename(".sqlite").to_s)),
    "copyright" => metadata["copyright"].to_s,
    "books" => books,
    "scriptures" => scriptures
  }
end

def write_bible_file(payload)
  BIBLES_DIR.mkpath
  output = BIBLES_DIR.join("#{payload.fetch("name")}.js")
  output.write(finish_payload(payload))
  puts "wrote #{output.relative_path_from(ROOT)}"
end

def convert_openlp_bibles
  OPENLP_DIR.glob("*.xmm").sort.each do |path|
    next if SKIP_OPENLP.include?(path.basename(".xmm").to_s)

    write_bible_file(build_from_openlp(path))
  end
end

def convert_sqlite_bibles
  path = SQLITE_DIR.join("Las_Sagradas_Escrituras.sqlite")
  return unless path.file?

  write_bible_file(build_from_sqlite(path))
end

def js_files
  BIBLES_DIR.glob("*.js").sort_by { |path| path.basename.to_s.downcase }
end

def html_script(path)
  relative = path.relative_path_from(DOCK_DIR).to_s
  %(<script src="#{URI::DEFAULT_PARSER.escape(relative)}" defer></script>)
end

def write_dock_index
  bible_scripts = js_files.map { |path| "    #{html_script(path)}" }.join("\n")
  DOCK_DIR.join("index.html").write(<<~HTML)
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <link rel="icon" href="./favicon.ico">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="Bible browser pane for OBS Studio.">
        <title>Dock | Bible Plugin for OBS Studio</title>
        <link href="./static/css/2.a9672c7c.chunk.css" rel="stylesheet">
        <link href="./static/css/main.58e53fae.chunk.css" rel="stylesheet">
      </head>
      <body>
        <noscript>You need to enable JavaScript to run this app.</noscript>
        <div id="root"></div>
        <div id="modal-root"></div>
        <script src="./static/js/runtime-main.4ba2aed3.js" defer></script>
        <script src="./static/js/2.b5a8ffa8.chunk.js" defer></script>
        <script src="./static/js/main.0e08c71a.chunk.js" defer></script>
        <div id="bible-scripts">
    #{bible_scripts}
        </div>
        <script src="bibles-loaded.js" defer></script>
      </body>
    </html>
  HTML
  puts "wrote #{DOCK_DIR.join("index.html").relative_path_from(ROOT)}"
end

convert_openlp_bibles
convert_sqlite_bibles
write_dock_index
