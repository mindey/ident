from setuptools import setup

with open('README.md', 'r', encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='ident',
    version='0.2',
    description='Identify with challenge messsage and SSH key.',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/mindey/ident',
    author='Mindey',
    author_email='~@mindey.com',
    license='MIT',
    packages=['ident'],
    install_requires=[
        "cryptography"
    ],
    entry_points={
        'console_scripts': [
            'ident=ident.cli:verify',
        ],
    },
    zip_safe=False
)
