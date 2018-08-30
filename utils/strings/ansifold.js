#!/usr/bin/env node

/**
 *	This is the kernel of the ansifold function in the script
 * `shell-utilities/strings.sh`. It counts visible (not part of ansi escape 
 * codes) characters and wraps text at 80 columns
 */

// FUTURE FEATURES:
//	- lineWidth should be parameterized
//  - should account for tabs.
//  - should account for double-width characters 這一樣.

var data='',
	lineWidth=80;

process.stdin.resume();
process.stdin.setEncoding('utf8');
process.stdin.on('data', function(chunk) {
	data += chunk;
});

process.stdin.on('end', function() {

	data = data.replace(/\n$/,'');

	// traverse the string, looking for \x1b..m sequences
	var splitline = data.split(/((\x1b\[[^m]*m)| )/),
		openAnsicodes = '',
		lineColCount = 0,
		output = '';

	for (var i = splitline.length - 1; i >= 0; i--) {
		if ('undefined' === typeof(splitline[i]) || '' === splitline[i]) {
			splitline.splice(i, 1);
		}
	}

	splitline.forEach(token => {

		// console.log('        token:', '\"'+token+'\"');
		// console.log('lineColCount :', lineColCount);
		// console.log('openAnsicodes:', openAnsicodes.replace(/\x1b/,'\\x1b'));

		if (token === '\x1b[0m') {
			// close an ansi code
			openAnsicodes = '';
			output += token;
		} else if (token.startsWith('\x1b[')) {
			// open an ansi code
			openAnsicodes += token;
			output += token;
		} else if (token === ' ') {
			// don't print spaces if it's on a new line of extends past the end of a line
			if (0 < lineColCount || lineWidth >= lineColCount) {
				output += token;
				lineColCount++;
			}
		} else if (lineColCount + token.length > lineWidth) {
			if (openAnsicodes.length > 0) {
				output += '\x1b[0m\n' + openAnsicodes
			} else {
				output += '\n'
			}
			output += token;
			lineColCount = token.length;
		} else {
			lineColCount += token.length;
			output += token;
		}

	});


	console.log(output);
});




