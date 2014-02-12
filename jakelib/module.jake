'use strict';

// Tasks to add modules to the project that are not included by default.
// This is usually either Bower packages or NPM packages.
var fs = require('fs');
var npm = require('./lib').bin('npm');

namespace('add', function() {
  desc('Add testing modules');
  task('testing', function() {
    editPackage(function() {
      this.devDependencies['karma-chai-plugins'] = '~0.2.0';
      this.devDependencies['karma-detect-browsers'] = '~0.1.2';
      this.devDependencies['karma-mocha'] = '~0.1.1';
      this.devDependencies['coffee-script'] = '~1.7.1';
      this.devDependencies['chai'] = '~1.9.0';
      this.devDependencies['mocha'] = '~1.17.1';
      this.devDependencies['mocha-as-promised'] = '~2.0.0';
      this.devDependencies['nodemon'] = '~1.0.14';
      this.devDependencies['phantomjs'] = '~1.9.2';
      this.devDependencies['selenium-webdriver'] = '~2.39.0';
    });
    return npm.execute('install');
  });

  desc('Add server extras');
  task('serverextras', function() {
    editPackage(function() {
      this.dependencies['bcryptjs'] = '~0.7.10';
      this.dependencies['connect-mongo'] = '~0.4.0';
      this.dependencies['mongoose'] = '~3.8.6';
      this.dependencies['passport'] = '~0.2.0';
      this.dependencies['passport-local'] = '~0.1.6';
      this.dependencies['prerender-node'] = '~0.1.15';
    });
    return npm.execute('install');
  });

  desc('Add jQuery');
  task('jquery', function() {
    editBower(function() {
      this.dependencies['jquery'] = '~2.1.0';
    });
  });

  desc('Add normalize.css');
  task('normalize', function() {
    editBower(function() {
      this.dependencies['normalize-css'] = '~3.0.0';
    });
  });

  desc('Add Lo-Dash');
  task('lodash', function() {
    editBower(function() {
      this.dependencies['lodash'] = '~2.4.1';
    });
  });

  desc('Add Rivets for better view/model data binding');
  task('rivets', function() {
    editBower(function() {
      this.dependencies['rivets'] = '~0.6.4';
      this.overrides.rivets = {
        main: 'dist/rivets.js'
      };
    });
  });

  desc('Add Exoskeleton (replaces Backbone, removes jQuery and Lodash)');
  task('exoskeleton', ['rem:jquery', 'rem:lodash'], function() {
    editBower(function() {
      this.dependencies['exoskeleton'] = '~0.6.1';
      this.overrides.chaplin = {
        dependencies: {
          exoskeleton: '*'
        }
      };
      delete this.overrides.backbone;
    });
  });

  desc('Add Davy for promise support (useful with Exoskeleton)');
  task('davy', function() {
    editBower(function() {
      this.dependencies['lodash'] = '~0.1.0';
    });
  });
});

namespace('rem', function() {
  desc('Remove testing modules');
  task('testing', function() {
    return npm.execute('uninstall', '--save-dev',
      'karma-chai-plugins',
      'karma-detect-browsers',
      'karma-mocha',
      'chai',
      'mocha',
      'mocha-as-promised',
      'nodemon',
      'phantomjs',
      'selenium-webdriver');
  });

  desc('Remove Server extras');
  task('serverextras', function() {
    return npm.execute('uninstall', '--save',
      'bcryptjs',
      'connect-mongo',
      'mongoose',
      'passport',
      'passport-local',
      'prerender-node');
  });

  desc('Remove jQuery');
  task('jquery', function() {
    editBower(function() {
      delete this.dependencies['jquery'];
    });
  });

  desc('Remove normalize.css');
  task('normalize', function() {
    editBower(function() {
      delete this.dependencies['normalize-css'];
    });
  });

  desc('Remove Lo-Dash');
  task('lodash', function() {
    editBower(function() {
      delete this.dependencies['lodash'];
    });
  });

  desc('Remove Rivets');
  task('rivets', function() {
    editBower(function() {
      delete this.dependencies['rivets'];
      delete this.overrides['rivets'];
    });
  });

  desc('Remove Exoskeleton (restores classic Backbone, jQuery, and Lo-Dash)');
  task('exoskeleton', ['add:jquery', 'add:lodash'], function() {
    editBower(function() {
      delete this.dependencies['exoskeleton'];
      this.overrides.backbone = {
        dependencies: {
          lodash: '*',
          jquery: '*'
        }
      };
    });
  });

  desc('Remove Davy');
  task('davy', function() {
    editBower(function() {
      delete this.dependencies['davy'];
    });
  });
});

function editBower(callback) {
  var json = JSON.parse(fs.readFileSync('bower.json'));
  callback.call(json);
  fs.writeFileSync('bower.json', JSON.stringify(json, null, 2) + '\n');
}

function editPackage(callback) {
  var json = JSON.parse(fs.readFileSync('package.json'));
  callback.call(json);
  fs.writeFileSync('package.json', JSON.stringify(json, null, 2) + '\n');
}
