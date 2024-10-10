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
  "displayName": "Clean or Redact PII from URLs",
  "description": "Cleans PII from URLs by redacting query parameters based on key or value, with support for regular expressions. Make sure to clean URLs to remove any PII before sending them to third parties.",
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
    "valueHint": "https://domain.com/path"
  },
  {
    "type": "PARAM_TABLE",
    "name": "paramKeys",
    "displayName": "Query Parameters Keys",
    "paramTableColumns": [
      {
        "param": {
          "type": "TEXT",
          "name": "regex",
          "displayName": "Regex",
          "simpleValueType": true,
          "help": "Examples: \u003csmall\u003e\u003cbr\u003eEmail: \u003cem\u003e[aA-zZ0-9._]+(@|%40)[aA-zZ0-9.-]+.[aA-zZ]\u003c/em\u003e\u003cbr\u003ePhone: \u003cem\u003e(\\+\\d+\\s)?\\(?\\d+\\)?[\\s.-]\\d+[\\s.-]\\d+\u003c/em\u003e\u003c/small\u003e",
          "valueValidators": [
            {
              "type": "NON_EMPTY"
            }
          ]
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "SELECT",
          "name": "redactOrDelete",
          "displayName": "Redact or delete",
          "macrosInSelect": false,
          "selectItems": [
            {
              "value": "Redact",
              "displayValue": "Redact"
            },
            {
              "value": "Delete",
              "displayValue": "Delete"
            }
          ],
          "simpleValueType": true,
          "help": "Redact the value to the desired text, or delete the parameter and value completely."
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "TEXT",
          "name": "replacement",
          "displayName": "Redact Replacement",
          "simpleValueType": true,
          "defaultValue": "[redacted]",
          "enablingConditions": [
            {
              "paramName": "redactOrDelete",
              "paramValue": "Redact",
              "type": "EQUALS"
            }
          ]
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "CHECKBOX",
          "name": "fullMatch",
          "checkboxText": "Full match",
          "simpleValueType": true,
          "help": "By default, the keys are treated as regular expressions. For example, \u003ccode\u003eutm_\u003c/code\u003e will match all parameter keys starting with \u003ccode\u003eutm_\u003c/code\u003e, such as \u003ccode\u003eutm_source\u003c/code\u003e and \u003ccode\u003eutm_medium\u003c/code\u003e. Check this box to disable regular expression matching and use exact key matching instead."
        },
        "isUnique": false
      }
    ],
    "newRowButtonText": "New Pattern",
    "alwaysInSummary": false,
    "help": "List the query parameter keys to redact/delete. Each key will be treated as a regular expression. For example, entering \u003ccode\u003eutm_\u003c/code\u003e will redact any query parameter keys starting with \u003ccode\u003eutm_\u003c/code\u003e. To use exact matches instead of regular expressions, check the \u003ccode\u003eparamKeysFullMatch\u003c/code\u003e checkbox below."
  },
  {
    "type": "PARAM_TABLE",
    "name": "paramValues",
    "displayName": "Query Parameters Values",
    "paramTableColumns": [
      {
        "param": {
          "type": "TEXT",
          "name": "regex",
          "displayName": "Regex",
          "simpleValueType": true,
          "help": "Examples: \u003csmall\u003e\u003cbr\u003eEmail: \u003cem\u003e[aA-zZ0-9._]+(@|%40)[aA-zZ0-9.-]+.[aA-zZ]\u003c/em\u003e\u003cbr\u003ePhone: \u003cem\u003e(\\+\\d+\\s)?\\(?\\d+\\)?[\\s.-]\\d+[\\s.-]\\d+\u003c/em\u003e\u003c/small\u003e"
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "SELECT",
          "name": "redactOrDelete",
          "displayName": "Redact or delete",
          "macrosInSelect": false,
          "selectItems": [
            {
              "value": "Redact",
              "displayValue": "Redact"
            },
            {
              "value": "Delete",
              "displayValue": "delete"
            }
          ],
          "simpleValueType": true,
          "help": "Redact the value to the desired text, or delete the parameter and value completely."
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "TEXT",
          "name": "replacement",
          "displayName": "Redact Replacement",
          "simpleValueType": true,
          "defaultValue": "[redacted]",
          "enablingConditions": [
            {
              "paramName": "redactOrDelete",
              "paramValue": "Redact",
              "type": "EQUALS"
            }
          ]
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
  paramKeys: data.paramKeys || [],
  paramValues: data.paramValues || [],
  // advanced
  decodeUri: getType(data.decodeUri) !== 'undefined' ? data.decodeUri : true
};

// functions

const doReplacements = function(text, row) {
  const match = text.match(row.regex);
  let textReplacement = row.replacement || '[redacted]';
  
  if (row.redactOrDelete && row.redactOrDelete == 'Delete') {
    textReplacement = '[delete]';
  }

  if (match) {
    return doReplacements(
      text.replace(match[0], textReplacement),
      row
    );
  }

  return text;
};


const shouldRedact = function(key, row) {
  // we find if any of the query patterns match
  if (row.fullMatch) {
     return row.regex == key; 
  }
  
  return key.match(row.regex);
};

// logic

const urlObject = config.decodeUri ? 
      parseUrl(decodeUriComponent(config.uri)) : parseUrl(config.uri);

// double checking 
if (getType(urlObject) === 'undefined' || !urlObject.search) {
  return config.uri;
}

const newParams = Object.entries(urlObject.searchParams).map((entry) => {
  // if the value type is not string (could be array), replacement is not supported 
  if (getType(entry[1]) !== 'string') {
    return entry[0] + '=' + entry[1];
  }
  
  for (let i = 0; i < config.paramKeys.length; i++) {
    let row = config.paramKeys[i];
    if (shouldRedact(entry[0], row)) {
      if (row.redactOrDelete && row.redactOrDelete == "Delete") {
        return null;
      }
      
      if (!entry[1]) {
        return entry[0] + '=';
      }
      
      return entry[0] + '=' + row.replacement;
    }
  }

  
  let paramValue = encodeUriComponent(entry[1]);
  
  paramValue = Object.values(config.paramValues)
    .reduce((value, row) => {
      return doReplacements(
        value, 
        row);
      }, paramValue);
  
  if (paramValue == '[delete]') {
    return null;
  }
  
  return entry[0] + '=' + paramValue;  
}, '').filter(a => a).join('&');


const newParamsText = newParams ? '?' + newParams : '';
// return
return urlObject.origin + urlObject.pathname + newParamsText + urlObject.hash;


___TESTS___

scenarios:
- name: Test parameter key patterns - Not decoding URI
  code: |-
    const mockData = {
      url: 'https://mydomain.com/?foo=bar&other_param=Keep&1_Param1=My%20Value%20Here&20_Name=John&30_Phone=123456890&30_Email=test%40domain.com&40_Message=this%20is%20just%20a%20test%20msg',
      paramKeys: [
        {
          regex: '\\d+',
          replacement: '[redacted]'
        }
      ],
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
      paramKeys: [
        {
          regex: '\\d+_',
          replacement: '[redacted]'
        }
      ],
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
      paramKeys: [
        {
          regex: '\\d+_',
          replacement: '[redacted]'
        }
      ],
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
      paramKeys: [
        {
          regex: '\\d+_',
          replacement: '[redacted]'
        }
      ],
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/subpath?success=1&10_Name=[redacted]&20_Email=[redacted]&30_Phone=[redacted]&40_Message=[redacted]');
- name: Test without query parameters
  code: |-
    const mockData = {
      url: 'https://www.test.com/mypath/',
      paramKeys: [
        {
          regex: '\\d+',
          replacement: '[redacted]'
        }
      ],
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/mypath/');
- name: Test with empty params
  code: |-
    const mockData = {
      url: 'https://www.test.com/mypath/?Foo=bar+foo&5_From_Page=https://www.site.com/&10_Name=&20_Email=support@test.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message,%20please%20ignore',
      paramKeys: [
        {
          regex: '\\d+_',
          replacement: '[redacted]'
        }
      ],
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/mypath/?Foo=bar%20foo&5_From_Page=[redacted]&10_Name=&20_Email=[redacted]&30_Phone=[redacted]&40_Message=[redacted]');
- name: Test splitting by |
  code: |-
    const mockData = {
      url: 'https://www.test.com/mypath/?foo=bar+foo&10_Name=&20_Email=support@test.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message,%20please%20ignore&utm_content=content&utm_source=newsletter&utm_medium=email',
      paramKeys: [
        {
          regex: 'foo',
          replacement: '[redacted]'
        },
        {
          regex: 'utm_',
          replacement: '[redacted]'
        },
        {
          regex: '\\d+',
          replacement: '[redacted]'
        },
      ],
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/mypath/?foo=[redacted]&10_Name=&20_Email=[redacted]&30_Phone=[redacted]&40_Message=[redacted]&utm_content=[redacted]&utm_source=[redacted]&utm_medium=[redacted]');
- name: Test key full match
  code: "const mockData = {\n  url: 'https://www.test.com/mypath/?foo=bar+foo&10_Name=test&utm_source=newsletter&utm_medium=email',\n\
    \  paramKeys: [\n    {\n      regex: 'foo',\n      replacement: '[redacted]',\n\
    \      fullMatch: true\n    },\n    {\n      regex: 'utm_',\n      replacement:\
    \ '[redacted]',\n      fullMatch: true      \n    },\n    {\n      regex: 'utm_medium',\n\
    \      replacement: '[redacted]',\n      fullMatch: true      \n    },    \n \
    \   {\n      regex: '\\\\d+',\n      replacement: '[redacted]',\n      fullMatch:\
    \ true      \n    },\n  ], \n  decodeUri: false\n};\n\n// Call runCode to run\
    \ the template's code.\nlet variableResult = runCode(mockData);\n\n// Verify that\
    \ the variable returns a result.\nassertThat(variableResult).isEqualTo('https://www.test.com/mypath/?foo=[redacted]&10_Name=test&utm_source=newsletter&utm_medium=[redacted]');"
- name: Test with param values - Delete no extra
  code: |-
    const mockData = {
      url: 'https://mydomain.com/?1_Phone=1234568900&2_Phone=123-456-8900&3_Phone=123.456.8900&4_Phone=(123)-456.8900&5_Phone=123 456 7890&6_Phone=+91(123) 456-7890',
      paramKeys: '',
      paramValues: [
        {
          regex: '(%20[0-9]+(%20| )?)?(\\(|%28)?[0-9]{3}(\\)|%29)?(%20| )?[.-]?[0-9]{3}(%20| )?[.-]?[0-9]{4}',
          replacement: '[phone]',
          redactOrDelete: 'Delete'
        }
      ],
      decodeUri: true
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://mydomain.com/');
- name: Test with param values - Delete with extra
  code: |-
    const mockData = {
      url: 'https://mydomain.com/?one=two&1_Phone=1234568900&2_Phone=123-456-8900&3_Phone=123.456.8900&4_Phone=(123)-456.8900&5_Phone=123 456 7890&6_Phone=+91(123) 456-7890&foo=bar',
      paramKeys: '',
      paramValues: [
        {
          regex: '(%20[0-9]+(%20| )?)?(\\(|%28)?[0-9]{3}(\\)|%29)?(%20| )?[.-]?[0-9]{3}(%20| )?[.-]?[0-9]{4}',
          replacement: '[phone]',
          redactOrDelete: 'Delete'
        }
      ],
      decodeUri: true
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://mydomain.com/?one=two&foo=bar');
- name: Test with param keys - Delete no extra
  code: |-
    const mockData = {
      url: 'https://www.test.com/subpath?10_Name=my%20name&20_Email=support@test.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message,%20please%20ignore',
      paramKeys: [
        {
          regex: '\\d+_',
          replacement: '[redacted]',
          redactOrDelete: 'Delete'
        }
      ],
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/subpath');
- name: Test with param keys - Delete extra
  code: |-
    const mockData = {
      url: 'https://www.test.com/subpath?success=1&10_Name=my%20name&20_Email=support@test.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message,%20please%20ignore',
      paramKeys: [
        {
          regex: '\\d+_',
          replacement: '[redacted]',
          redactOrDelete: 'Delete'
        }
      ],
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/subpath?success=1');
- name: Test with no keys or values
  code: |-
    const mockData = {
      url: 'https://www.test.com/subpath?success=1&10_Name=my%20name&20_Email=support@test.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message,%20please%20ignore',
      decodeUri: false
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('https://www.test.com/subpath?success=1&10_Name=my%20name&20_Email=support%40test.com&30_Phone=1234567890&40_Message=this%20is%20a%20test%20message%2C%20please%20ignore');


___NOTES___

Created on 10/10/2024, 12:47:49 AM


