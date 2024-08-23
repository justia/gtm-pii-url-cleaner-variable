___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "PII - URL Cleaner",
  "description": "Removes PII from URLs by redacting query parameters based on key or value, with support for regular expressions. Make sure to clean URLs to remove any PII before sending them to analytics or third-par",
  "containerContexts": [
    "WEB"
  ],
  "categories": [
    "UTILITY"
  ]  
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "url",
    "displayName": "URL",
    "simpleValueType": true,
    "valueHint": "https://domain.com"
  },
  {
    "type": "TEXT",
    "name": "replacement",
    "displayName": "Replacement",
    "simpleValueType": true,
    "defaultValue": "[redacted]"
  },
  {
    "type": "TEXT",
    "name": "paramKeys",
    "displayName": "Query Parameter Keys",
    "simpleValueType": true,
    "defaultValue": "name|email|token",
    "help": "List the query parameter keys to replace, separated by \u0027|\u0027. Each key will be treated as a regular expression. For example, entering \u003ccode\u003eutm_\u003c/code\u003e will redact any query parameter keys starting with \u003ccode\u003eutm_\u003c/code\u003e. To use exact matches instead of regular expressions, check the \u003ccode\u003eparamKeysFullMatch\u003c/code\u003e checkbox below."
  },
  {
    "type": "CHECKBOX",
    "name": "paramKeysFullMatch",
    "checkboxText": "Keys Full Match",
    "simpleValueType": true,
    "help": "By default, the keys are treated as regular expressions. For example, \u003ccode\u003eutm_\u003c/code\u003e will match all parameter keys starting with \u003ccode\u003eutm_\u003c/code\u003e, such as \u003ccode\u003eutm_source\u003c/code\u003e and \u003ccode\u003eutm_medium\u003c/code\u003e. Check this box to disable regular expression matching and use exact key matching instead."
  },
  {
    "type": "PARAM_TABLE",
    "name": "paramValues",
    "displayName": "Query Parameterers Values",
    "paramTableColumns": [
      {
        "param": {
          "type": "TEXT",
          "name": "regex",
          "displayName": "Regular Expression",
          "simpleValueType": true,
          "help": "Examples: \u003csmall\u003e\u003cbr\u003eEmail: \u003cem\u003e[aA-zZ0-9._]+(@|%40)[aA-zZ0-9.-]+.[aA-zZ]\u003c/em\u003e\u003cbr\u003ePhone: \u003cem\u003e(\\+\\d+\\s)?\\(?\\d+\\)?[\\s.-]\\d+[\\s.-]\\d+\u003c/em\u003e\u003c/small\u003e"
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "TEXT",
          "name": "replacement",
          "displayName": "Replacement",
          "simpleValueType": true,
          "defaultValue": "[redacted]"
        },
        "isUnique": false
      }
    ],
    "newRowButtonText": "New Pattern",
    "alwaysInSummary": false,
    "help": "Query parameter values with dynamic or unknown keys can be redacted if the value matches a specified regular expression."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// APIs
// const log = require('logToConsole');
const decodeUri = require('decodeUri');
const decodeUriComponent = require('decodeUriComponent');

const encodeUriComponent = require('encodeUriComponent');
const Object = require('Object');
const getType = require('getType');
const parseUrl = require('parseUrl');

// Inputs
const config = {
  // 
  uri: data.url || '',
  replaceEmails: data.replaceEmails || false,
  replacement: data.replacement || '[redacted]',
  paramKeys: data.paramKeys ? data.paramKeys.split('|') : [],
  paramValues: data.paramValues || [],
  // advanced
  fullMatch: getType(data.paramKeysFullMatch) !== 'undefined' ? data.paramKeysFullMatch : false,
  decodeUri: getType(data.decodeUri) !== 'undefined' ? data.decodeUri : true
};

// functions

const doReplacements = function(str, regex, replacement) {
  const match = str.match(regex);

  if (match) {
    return doReplacements(
      str.replace(match[0], replacement),
      regex,
      replacement
    );
  }

  return str;
};


const shouldEncode = function(config, entry) {
  // if the value type is not string (could be array), return false  
  if (getType(entry[1]) !== 'string' || !entry[1]) {
    return false;
  }

  const key = entry[0];

  // note Array.prototype.find not available: 
  // note Array.prototype.includes not available: 
  // TypeError: Object has no 'find' property.
  // TypeError: Object has no 'includes' property.
  
  // we find if any of the query patterns match 
  return config.paramKeys
    .filter((pattern) => {
      if (config.fullMatch) {
        return key == pattern;
      }
      return key.match(pattern);
    })
    .length > 0;
};

// logic

const urlObject = config.decodeUri ? 
      parseUrl(decodeUriComponent(config.uri)) : parseUrl(config.uri);

// double checking 
if (getType(urlObject) === 'undefined' || !urlObject.search) {
  return config.uri;
}

const newParams = Object.entries(urlObject.searchParams).map((entry) => {
  if (shouldEncode(config, entry)) {
    return entry[0] + '=' + config.replacement;
  }
  
  let paramValue = encodeUriComponent(entry[1]);
  paramValue = Object.values(config.paramValues)
    .reduce((value, pattern) => {
      return doReplacements(value, pattern.regex, pattern.replacement);
  }, paramValue);  
  
  
  return entry[0] + '=' + paramValue;  
}, '').join('&');

// return
return urlObject.origin + urlObject.pathname + '?' + newParams + urlObject.hash;


___TESTS___

scenarios:
- name: Test parameter key patterns - Not decoding URI
  code: |-
    const mockData = {
      url: 'https://mydomain.com/?foo=bar&other_param=Keep&1_Param1=My%20Value%20Here&20_Name=John&30_Phone=123456890&30_Email=test%40domain.com&40_Message=this%20is%20just%20a%20test%20msg',
      paramKeys: '\\d+',
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://mydomain.com/?foo=bar&other_param=Keep&1_Param1=[redacted]&20_Name=[redacted]&30_Phone=[redacted]&30_Email=[redacted]&40_Message=[redacted]');
- name: Test parameter key patterns - Decoding URI
  code: |-
    const mockData = {
      url: 'https://mydomain.com/?foo=bar&other=Keep&1_Value=My%20Values%20Here&10_Name=Maria&20_Phone=123456890&30_Email=test%40domain.com&40_Message=this%20is%20just%20a%20test%20msg',
      paramKeys: '\\d+_',
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://mydomain.com/?foo=bar&other=Keep&1_Value=[redacted]&10_Name=[redacted]&20_Phone=[redacted]&30_Email=[redacted]&40_Message=[redacted]');
- name: Test parameter key patterns - Double encoding
  code: |-
    const mockData = {
      url: 'https://mydomain.com/?foo=bar&1_Param=My%252520Test%252520Message&10_Name=test&20_Phone=123456890&30_Email=test%40domain.com&40_Message=this%2520is%2520just%2520a%2520test%2520msg',
      paramKeys: '\\d+_',
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://mydomain.com/?foo=bar&1_Param=[redacted]&10_Name=[redacted]&20_Phone=[redacted]&30_Email=[redacted]&40_Message=[redacted]');
- name: Test param values
  code: |-
    const mockData = {
      url: 'https://mydomain.com/?30_Email=test%40domain.com&foo=bar',
      paramKeys: '',
      paramValues: [
        {
          regex: '[aA-zZ0-9._]+(@|%40)[aA-zZ0-9.-]+.[aA-zZ]',
          replacement: '[email]'
        }
      ],
      decodeUri: true
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://mydomain.com/?30_Email=[email]&foo=bar');
- name: Test param values 2
  code: |-
    const mockData = {
      url: 'https://mydomain.com/?1_Phone=1234568900&2_Phone=123-456-8900&3_Phone=123.456.8900&4_Phone=(123)-456.8900&5_Phone=123 456 7890&6_Phone=+91(123) 456-7890&foo=bar',
      paramKeys: '',
      paramValues: [
        {
          regex: '(%20[0-9]+(%20| )?)?(\\(|%28)?[0-9]{3}(\\)|%29)?(%20| )?[.-]?[0-9]{3}(%20| )?[.-]?[0-9]{4}',
          replacement: '[phone]'
        }
      ],
      decodeUri: true
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://mydomain.com/?1_Phone=[phone]&2_Phone=[phone]&3_Phone=[phone]&4_Phone=[phone]&5_Phone=[phone]&6_Phone=[phone]&foo=bar');
- name: Test with spaces
  code: |-
    const mockData = {
      url: 'https://www.test.com/subpath?success=1&10_Name=my%20name&20_Email=support@test.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message,%20please%20ignore',
      paramKeys: '\\d+',
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/subpath?success=1&10_Name=[redacted]&20_Email=[redacted]&30_Phone=[redacted]&40_Message=[redacted]');
- name: Test without query parameters
  code: |-
    const mockData = {
      url: 'https://www.test.com/thank-you-info/',
      paramKeys: '\\d+',
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/thank-you-info/');
- name: Test with empty params
  code: |-
    const mockData = {
      url: 'https://www.test.com/thank-you-info/?Foo=bar+foo&5_From_Page=https://www.site.com/&10_Name=&20_Email=support@justia.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message,%20please%20ignore',
      paramKeys: '\\d+',
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/thank-you-info/?Foo=bar%20foo&5_From_Page=[redacted]&10_Name=&20_Email=[redacted]&30_Phone=[redacted]&40_Message=[redacted]');
- name: Test splitting by |
  code: |-
    const mockData = {
      url: 'https://www.test.com/thank-you-info/?foo=bar+foo&10_Name=&20_Email=support@justia.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message,%20please%20ignore&utm_content=content&utm_source=newsletter&utm_medium=email',
      paramKeys: 'foo|utm_|\\d+',
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/thank-you-info/?foo=[redacted]&10_Name=&20_Email=[redacted]&30_Phone=[redacted]&40_Message=[redacted]&utm_content=[redacted]&utm_source=[redacted]&utm_medium=[redacted]');
- name: Test key full match
  code: |-
    const mockData = {
      url: 'https://www.test.com/thank-you-info/?foo=bar+foo&10_Name=test&utm_source=newsletter&utm_medium=email',
      paramKeys: 'foo|utm_|utm_medium|\\d+',
      paramKeysFullMatch: true,
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/thank-you-info/?foo=[redacted]&10_Name=test&utm_source=newsletter&utm_medium=[redacted]');


___NOTES___

Created on 8/23/2024, 2:05:59 AM


