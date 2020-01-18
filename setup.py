from setuptools import setup

setup(
    name='ident',
    version='0.1',
    description='Identify with challenge messsage and SSH key.',
    url='https://github.com/mindey/ident',
    author='Mindey',
    author_email='mindey@qq.com',
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
