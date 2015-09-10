# test script suitable for git bisect
# usage: git bisect start v1.2.1 v1.2.0  && git bisect run ./test-script.sh

# delete node_modules to avoid errors on `npm install` - does not delete .bin
rm -r node_modules/*

npm install && npm run bundle || exit 1

# install the karma browser runner
if [[ -e backup-karma-dir ]]; then
    echo "Reusing previous Karma download"
    cp -r backup-karma-dir/* node_modules/
else
    #reinstall
    npm install karma karma-phantomjs-launcher karma-mocha

    # save for later for speed up
    mkdir backup-karma-dir
    pushd node_modules
    cp -r karma* phantomjs mocha ../backup-karma-dir/
    popd
fi

# make a karma config
cat > karma.conf << EOF

module.exports = function (config) {
	config.set({
		basePath : '.',

		// frameworks to use
		frameworks : ['mocha'],

        reporters : ['progress'],

		// list of files / patterns to load in the browser
		files : [
            'lolex.js', // the newly built bundle
			'setImmediate-shim.js',
			'setImmediate-test.js'
		],

		browsers : ['PhantomJS'],
        singleRun : true
	});
};
EOF

if [[ ! -e setImmediate-shim.js ]]; then
    echo "Downloading setImmediate shim"
    curl -s -o setImmediate-shim.js 'https://raw.githubusercontent.com/YuzuJS/setImmediate/master/setImmediate.js'
fi

if [[ ! -e setImmediate-test.js ]]; then
    echo "Downloading tests"
    curl -s -o setImmediate-test.js 'https://raw.githubusercontent.com/fatso83/Sinon.JS/setImmediate-bug/test/setImmediate-bug/setImmediate.test.js'
fi

# run the tests
./node_modules/.bin/karma start  karma.conf
