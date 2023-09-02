from setuptools import setup, find_packages
from typing import List

HYPEN_DOT="-e ."


def get_requirements(file_path:str)->List:
    '''
    This function will install all require libraries
    '''
    requirements = []
    with open(file_path) as f:
        requirements = f.readlines()
        requirements = [i.replace("\n","") for i in requirements]
    
    if HYPEN_DOT in requirements:
        requirements.remove(HYPEN_DOT)
    
    return requirements


    
setup(
    name="EDA Project Air Traffic Statistics",
    version = '0.0.1',
    author='Aditya',
    pacakges = find_packages(),
    install_packages = get_requirements('requirements.txt')
)