/**
 * mkdoc.js - Create the README.md file to match the current features
 */

const handlebars = require('handlebars')
const YAML = require('yaml')
const fs = require('fs').promises
const bluebird = require('bluebird')

// Build feature objects

bluebird
    .reduce(
        ['feature', 'flavour'],
        (docObjects, part) => {
            return fs
                .readdir(part)
                .then(partNames => {
                    return bluebird.reduce(
                        partNames,
                        (docObject, partName) => {
                            return fs.readFile(`${part}/${partName}/${part}.yaml`, { encoding: 'utf8' }).then(featureDescriptor => {
                                docObject[partName] = YAML.parse(featureDescriptor)
                                return docObject
                            })
                        },
                        {}
                    )
                })
                .then(docObject => {
                    docObjects[part] = docObject
                    return docObjects
                })
        },
        {}
    )
    .then(docObjects => {
        return fs.readFile('README.md.handlebars', { encoding: 'utf8' }).then(readmeTemplateSource => {
            const readmeTemplate = handlebars.compile(readmeTemplateSource)
            return readmeTemplate({
                docObjects: docObjects
            })
        })
    })
    .then(readme => {
        return fs.writeFile('README.md', readme)
    })
