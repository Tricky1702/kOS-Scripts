kOS-Lib-Docs
============

The documents are generated using Sphinx restructured text, with the ReadTheDocs
theme.

#Getting started on Windows

(For this example, the KOS repository is assumed to be located at `C:\KOS`,
you should adjust your path based on your actual repository location)

1. If you don't already have Python installed, install the latest version in the
  2.7 series.  At the time of this writing, 2.7.11 was the most current version.
  You may download the installer from: https://www.python.org/downloads/

2. You can verify the installation and version of Python (and pip) by issuing
  the following commands from the command line:
  ```
  C:\>python --version
  Python 2.7.11
  C:\>pip --version
  pip
  ```

3. Install the Sphinx engine
  ```
  C:\>pip install sphinx
  ```

4. Ensure that the read the docs template is installed.
  ```
  C:\>pip install sphinx_rtd_theme
  ```

5. Switch to the docs directory and run the make batch file:
  ```
  C:\>cd KOS\kOS-Lib-Docs
  C:\KOS\kOS-Lib-Docs>make clean
  C:\KOS\kOS-Lib-Docs>make html
  ```

6. Review the output for errors and warnings.  In the above example you would
  find the compiled html files at `C:\KOS\kOS-Lib-Docs\build\html`

7. (Optional) You may browse the generated html using file urls, or by using
  Python's included SimpleHTTPServer:
  ```
  C:\KOS\kOS-Lib-Docs>cd build\html
  C:\KOS\kOS-Lib-Docs\build\html>python -m SimpleHTTPServer 8000
  Serving HTTP on 0.0.0.0 port 8000...
  ```

  At which point you can point your browser to `http://localhost:8000`

#Getting started on Linux
1. As with Windows above, install Python 2.7.  You may use your distribution's
  package manager system, or download from: https://www.python.org/downloads/

2. All other instructions are the same as above for windows, replacing the `\`
  path character with `/` and adapting paths to reference your Linux file system.
