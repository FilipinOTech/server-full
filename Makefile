VIRTUALENV = virtualenv
PYTHON = bin/python
EZ = bin/easy_install
NOSE = bin/nosetests -s --with-xunit
FLAKE8 = bin/flake8
COVEROPTS = --cover-html --cover-html-dir=html --with-coverage --cover-package=synccore,syncreg,syncstorage
TESTS = deps/server-core/synccore/tests/ deps/server-core/services/tests deps/server-reg/syncreg/tests deps/server-storage/syncstorage/tests
PKGS = deps/server-core/synccore deps/server-core/services deps/server-reg/syncreg deps/server-storage/syncstorage
COVERAGE = bin/coverage
PYLINT = bin/pylint
PYPI2RPM = bin/pypi2rpm.py

.PHONY: all build mysqltest ldaptest test coverage build_extras qa oldtest hudson-coverage lint memcachedtest memcachedldaptest build_rpm2

all:	build

# XXX we could switch to zc.buildout here
build:
	$(VIRTUALENV) --no-site-packages --distribute .
	$(PYTHON) build.py

build_extras:
	$(EZ) nose
	$(EZ) coverage
	$(EZ) flake8
	$(EZ) mysql-python
	$(EZ) pylint
	$(EZ) pygments
	$(EZ) python-memcached
	$(EZ) pypi2rpm

memcachedtest:
	WEAVE_TESTFILE=memcached $(NOSE) $(TESTS)

memcachedldaptest:
	WEAVE_TESTFILE=memcachedldap $(NOSE) $(TESTS)

mysqltest:
	WEAVE_TESTFILE=mysql $(NOSE) $(TESTS)

ldaptest:
	WEAVE_TESTFILE=ldap $(NOSE) $(TESTS)

test:
	$(NOSE) $(TESTS)

coverage:
	rm -rf html
	- WEAVE_TESTFILE=mysql $(NOSE) $(COVEROPTS) $(TESTS)
	- WEAVE_TESTFILE=ldap $(NOSE) $(COVEROPTS) $(TESTS)
	- $(NOSE) $(COVEROPTS) $(TESTS)

hudson-coverage:
	cd deps/server-core; hg pull; hg up -C
	cd deps/server-reg; hg pull; hg up -C
	cd deps/server-storage; hg pull; hg up -C
	rm -f coverage.xml
	- $(COVERAGE) run --source=syncreg,synccore,syncstorage,services $(NOSE) $(TESTS); $(COVERAGE) xml

lint:
	rm -f pylint.txt
	- $(PYLINT) -f parseable --rcfile=pylintrc $(PKGS) > pylint.txt

qa:
	rm -f deps/server-reg/syncreg/templates/*.py
	$(FLAKE8) $(PKGS)

oldtest:
	$(PYTHON) tests/functional/run_server_tests.py

build_rpms:
	rm -rf $(CURDIR)/rpms
	mkdir $(CURDIR)/rpms
	$(PYPI2RPM) --dist-dir=$(CURDIR)/rpms webob
	$(PYPI2RPM) --dist-dir=$(CURDIR)/rpms paste 
	$(PYPI2RPM) --dist-dir=$(CURDIR)/rpms pastedeploy 
	$(PYPI2RPM) --dist-dir=$(CURDIR)/rpms sqlalchemy 
	$(PYPI2RPM) --dist-dir=$(CURDIR)/rpms mako 
	$(PYPI2RPM) --dist-dir=$(CURDIR)/rpms simplejson
	cd deps/server-core; rm -rf build; ../../$(PYTHON) setup.py --command-packages=pypi2rpm.command bdist_rpm2 --spec-file=SyncCore.spec --dist-dir=$(CURDIR)/rpms
	cd deps/server-storage; rm -rf build;../../$(PYTHON) setup.py --command-packages=pypi2rpm.command bdist_rpm2 --spec-file=SyncStorage.spec --binary-only --dist-dir=$(CURDIR)/rpms
	cd deps/server-reg; rm -rf build;../../$(PYTHON) setup.py --command-packages=pypi2rpm.command bdist_rpm2 --spec-file=SyncReg.spec --dist-dir=$(CURDIR)/rpms


