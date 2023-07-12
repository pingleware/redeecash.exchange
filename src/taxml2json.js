"use strict"
const yargs = require('yargs');

const argv = yargs
    .option('cik',{
        description: 'SEC CIK Number',
        type: 'string',
        default: '1961658',
        required: false
    })
    .option('accession_number',{
      description: 'Accession Number for the filing',
      type: 'string',
      default: '000196165823000002',
      required: false
    })
    .help()
    .alias('help', '?').argv;

const axios = require('axios');
const xml2js = require('xml2js');

const url = `https://www.sec.gov/Archives/edgar/data/${argv.cik}/${argv.accession_number}/primary_doc.xml`;

axios.get(url)
  .then(response => {
    const xml = response.data;
    const parser = new xml2js.Parser();
    
    parser.parseString(xml, (err, result) => {
      if (err) {
        console.error('Error parsing XML:', err);
      } else {
        const json = JSON.stringify(result, null, 2);
        console.log(json);
      }
    });
  })
  .catch(error => {
    console.error('Error retrieving XML:', error);
  });
