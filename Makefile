DEPS = server-core,server-reg,server-storage
PYTHON = `which python2 python | head -n 1`
VIRTUALENV = virtualenv --python=$(PYTHON)
NOSE = bin/nosetests -s --with-xunit
TESTS = deps/server-core/services/tests deps/server-reg/syncreg/tests deps/server-storage/syncstorage/tests
SERVER = dev-auth.services.mozilla.com
SCHEME = https
BUILDAPP = bin/buildapp
BUILDRPMS = bin/buildrpms
PYPI = http://pypi.python.org/simple
PYPIOPTIONS = -i $(PYPI)
CHANNEL = prod
INSTALL = bin/pip install
INSTALLOPTIONS = -U -i $(PYPI)

ifdef PYPIEXTRAS
	PYPIOPTIONS += -e $(PYPIEXTRAS)
	INSTALLOPTIONS += -f $(PYPIEXTRAS)
endif

ifdef PYPISTRICT
	PYPIOPTIONS += -s
	ifdef PYPIEXTRAS
		HOST = `python -c "import urlparse; print urlparse.urlparse('$(PYPI)')[1] + ',' + urlparse.urlparse('$(PYPIEXTRAS)')[1]"`

	else
		HOST = `python -c "import urlparse; print urlparse.urlparse('$(PYPI)')[1]"`
	endif
	INSTALLOPTIONS += --install-option="--allow-hosts=$(HOST)"

endif

INSTALL += $(INSTALLOPTIONS)


.PHONY: all build update test build_rpms


all:	build

build:
	$(VIRTUALENV) --distribute --no-site-packages .
	$(INSTALL) Distribute
	$(INSTALL) MoPyTools
	$(INSTALL) Nose
	$(INSTALL) WebTest
	$(BUILDAPP) -c $(CHANNEL) $(PYPIOPTIONS) $(DEPS)
	# Pre-compile mako templates into the correct directories.
	for TMPL in `find . -name '*.mako'`; do ./bin/python -c "from mako.template import Template; Template(filename='$$TMPL', module_directory='`dirname $$TMPL`', uri='`basename $$TMPL`')"; done;

update:
	$(BUILDAPP) -c $(CHANNEL) $(PYPIOPTIONS) $(DEPS)
	# Pre-compile mako templates into the correct directories.
	for TMPL in `find . -name '*.mako'`; do ./bin/python -c "from mako.template import Template; Template(filename='$$TMPL', module_directory='`dirname $$TMPL`', uri='`basename $$TMPL`')"; done;

test:
	$(NOSE) $(TESTS)

build_rpms:
	$(BUILDRPMS) -c $(CHANNEL) $(DEPS)
