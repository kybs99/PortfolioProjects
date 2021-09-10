import streamlit as st # this is what we will use for the webframework
import pandas as pd # this is what we will use to display the data
from PIL import Image # this is what we will use to display image on the website
import subprocess  # this is how we will get the descriptor calculation to work
import os # this is how we will do file handling
import base64 # This is to encode and decode the file
import pickle # This is how we import our model


# Molecular descriptor calculator
def desc_calc():
    # Performs the PaDEL descriptor calculation
    bashCommand= "java -Xms2G -Xmx2G -Djava.awt.headless=true -jar ./PaDEL-Descriptor/PaDEL-Descriptor.jar -removesalt -standardizenitro -fingerprints -descriptortypes ./PaDEL-Descriptor/PubchemFingerprinter.xml -dir ./ -file descriptors_output.csv"
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    os.remove('molecule.smi')


# File download
def filedownload(df):
    csv = df.to_csv(index=False)
    b64 = base64.b64encode(csv.encode()).decode() # This converts the strings to bites and vise versa
    href = f'<a href="data:file/csv;base64,{b64}" download="prediction.csv">Download Predictions</a>'
    return href

# Model Building
def build_model(input_data):
    # Reads in the saved RF Regression model
    load_model = pickle.load(open('egfr_model.pkl', 'rb')) #r**2 value of this model was ~0.687
    # Apply the model to make predictions
    prediction = load_model.predict(input_data)
    st.header('**Prediction Output**')
    prediction_output = pd.Series(prediction, name='pIC50')
    molecule_name = pd.Series(load_data[1], name='molecule_name')
    df = pd.concat([molecule_name, prediction_output], axis=1)
    st.write(df)
    st.markdown(filedownload(df), unsafe_allow_html=True)
    
# Still writing the code from Data Professor
# Unsure what the load_data[1] in line 41 is coming from
# will wait until he talks about that section before continuing

# Logo image
image = Image.open('logo.png')

st.image(image, use_column_width=True)

# Page Title
st.markdown("""
# Bioactivity Prediction App (Epidermal Growth Factor Receptor EGFR)

This app allows you to predict the bioactivity towards inhibiting the EGFR protein. EGFR is a drug target for colon and lung cancer.

**Credits**
- App build in `Python` + `Streamlit` inspired by [Chanin Nantasenamat](https://medium.com/@chanin.nantasenamat) (aka [Data Professor](http://youtube.com/dataprofessor))
- Descriptor calculated using [PaDEL-Descriptor](http://www.yapcwsoft.com/dd/padeldescriptor/) [[Read the Paper]](https://doi.org/10.1002/jcc.21707).
---
""")

# Sidebar 
with st.sidebar.header('1. Upload your CSV data'):
    uploaded_file = st.sidebar.file_uploader("Upload your input file", type=['txt'])
    st.sidebar.markdown("""
[Example input file](https://raw.githubusercontent.com/dataprofessor/bioactivity-prediction-app/main/example_acetylcholinesterase.txt)
""")

if st.sidebar.button('Predict'):
    load_data = pd.read_table(uploaded_file, sep=' ', header=None)
    load_data.to_csv('molecule.smi', sep = '\t', header=False, index=False)
    
    st.header('**Original input data**')
    st.write(load_data)
    
    with st.spinner("Calculating descriptors..."):
        desc_calc()
    
    # Read in calculated descriptors and display the dataframe
    st.header('**Calculated molecular descriptors**')
    desc = pd.read_csv('descriptors_output.csv')
    st.write(desc)
    st.write(desc.shape)
    
    # Read in calculated descriptors and display the DF
    st.header('**Subset of descriptors from previously built models**')
    Xlist = list(pd.read_csv('descriptor_list.csv').columns)
    desc_subset = desc[Xlist]
    st.write(desc_subset)
    st.write(desc_subset.shape)
    
    # Apply trained model to make prediction on query commands
    build_model(desc_subset)
else:
    st.info('Upload input data in the sidebar to start')
