#!/bin/sh

set -eu;

output="${1-./build}";
echo "Building to: '${output}'";

mkdir -p "${output}";

# Workaround for running as root
# https://github.com/mermaid-js/mermaid-cli/blob/master/docs/linux-sandbox-issue.md

PUPPETEER_CONFIG="";
if [ "$(id -u)" -eq 0 ] && [ -n "${CI}" ]; then
	PUPPETEER_CONFIG="puppeteer-config.json";
	echo '{ "args": ["--no-sandbox"] }' > "${PUPPETEER_CONFIG}";
	PUPPETEER_CONFIG=$(realpath "${PUPPETEER_CONFIG}");
fi

# Build presentations
asciidoctor-revealjs -vw -r asciidoctor-diagram \
	${PUPPETEER_CONFIG:+-a "mermaid-puppeteer-config=${PUPPETEER_CONFIG}"} \
	"presentations/Synthesizer.adoc" \
	-o "${output}/presentations/Synthesizer.html";
asciidoctor-revealjs -vw -r asciidoctor-diagram \
	${PUPPETEER_CONFIG:+-a "mermaid-puppeteer-config=${PUPPETEER_CONFIG}"} \
	"presentations/GUI.adoc" \
	-o "${output}/presentations/GUI.html";
cp -r \
	"presentations/images" \
	"presentations/style.css" \
    "papers_synthesizer" \
	"${output}/presentations";

asciidoctor -vw "README.adoc" -o "${output}/index.html";
cp -r "papers_synthesizer" \
    "${output}/papers_synthesizer";

echo "Build complete";
