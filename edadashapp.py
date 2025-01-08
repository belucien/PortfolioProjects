import streamlit as st
import pandas as pd
import json
from PyPDF2 import PdfReader
import chardet
import plotly.express as px

# Function to detect and handle file encoding
def detect_encoding(file):
    result = chardet.detect(file.read(10000))  # Analyze the first 10KB of the file
    file.seek(0)  # Reset file pointer to the beginning
    return result['encoding']

# Function to parse CSV files
def parse_csv(file):
    try:
        return pd.read_csv(file)
    except UnicodeDecodeError:
        encoding = detect_encoding(file)
        return pd.read_csv(file, encoding=encoding)

# Function to parse Excel files
def parse_excel(file):
    return pd.read_excel(file)

# Function to parse JSON files
def parse_json(file):
    data = json.load(file)
    return pd.json_normalize(data)

# Function to parse PDF files (extracting text as placeholder)
def parse_pdf(file):
    reader = PdfReader(file)
    text = ""
    for page in reader.pages:
        text += page.extract_text()
    return pd.DataFrame({"Content": [text]})

# Function to generate visualizations dynamically
def generate_visualizations(df):
    st.write("### Data Visualizations")

    # Identify column types
    numerical_columns = df.select_dtypes(include=['int64', 'float64']).columns.tolist()
    categorical_columns = df.select_dtypes(include=['object']).columns.tolist()
    datetime_columns = df.select_dtypes(include=['datetime64']).columns.tolist()

    # Histogram for numerical data
    if numerical_columns:
        st.write("#### Histogram")
        col = st.selectbox("Select a numerical column for the histogram:", numerical_columns, key="histogram")
        fig = px.histogram(df, x=col, title=f"Distribution of {col}")
        st.plotly_chart(fig)

    # Bar chart for categorical vs numerical
    if categorical_columns and numerical_columns:
        st.write("#### Bar Chart")
        cat_col = st.selectbox("Select a categorical column:", categorical_columns, key="bar_cat")
        num_col = st.selectbox("Select a numerical column:", numerical_columns, key="bar_num")
        fig = px.bar(df, x=cat_col, y=num_col, title=f"{num_col} by {cat_col}")
        st.plotly_chart(fig)

    # Pie chart for categorical data
    if categorical_columns:
        st.write("#### Pie Chart")
        col = st.selectbox("Select a categorical column for the pie chart:", categorical_columns, key="pie")
        fig = px.pie(df, names=col, title=f"Distribution of {col}")
        st.plotly_chart(fig)

    # Scatter plot for numerical relationships
    if len(numerical_columns) > 1:
        st.write("#### Scatter Plot")
        x_col = st.selectbox("Select X-axis column:", numerical_columns, key="scatter_x")
        y_col = st.selectbox("Select Y-axis column:", numerical_columns, key="scatter_y")
        fig = px.scatter(df, x=x_col, y=y_col, title=f"{y_col} vs {x_col}")
        st.plotly_chart(fig)

    # Line chart for time series data
    if datetime_columns and numerical_columns:
        st.write("#### Line Chart")
        time_col = st.selectbox("Select a datetime column:", datetime_columns, key="line_time")
        num_col = st.selectbox("Select a numerical column for the line chart:", numerical_columns, key="line_num")
        fig = px.line(df, x=time_col, y=num_col, title=f"{num_col} over {time_col}")
        st.plotly_chart(fig)

    # Box plot for numerical data
    if categorical_columns and numerical_columns:
        st.write("#### Box Plot")
        cat_col = st.selectbox("Select a categorical column for the box plot:", categorical_columns, key="box_cat")
        num_col = st.selectbox("Select a numerical column for the box plot:", numerical_columns, key="box_num")
        fig = px.box(df, x=cat_col, y=num_col, title=f"{num_col} by {cat_col}")
        st.plotly_chart(fig)

# Function to generate data insights
def generate_insights(df):
    st.write("### Data Insights")

    # Display basic data info
    st.write("#### Basic Information")
    st.write(f"Number of rows: {df.shape[0]}")
    st.write(f"Number of columns: {df.shape[1]}")

    # Display missing values
    st.write("#### Missing Values")
    missing_values = df.isnull().sum()
    st.dataframe(missing_values[missing_values > 0])

    # Display summary statistics
    st.write("#### Summary Statistics")
    st.dataframe(df.describe())

# Streamlit UI Setup
st.title("Interactive Data Dashboard")

# File uploader
uploaded_file = st.file_uploader("Upload a file (.csv, .xlsx, .json, .pdf):", type=["csv", "xlsx", "json", "pdf"])

if uploaded_file:
    file_type = uploaded_file.name.split(".")[-1].lower()

    try:
        if file_type == "csv":
            df = parse_csv(uploaded_file)
        elif file_type == "xlsx":
            df = parse_excel(uploaded_file)
        elif file_type == "json":
            df = parse_json(uploaded_file)
        elif file_type == "pdf":
            df = parse_pdf(uploaded_file)
        else:
            st.error("Unsupported file type!")

        # Display the DataFrame
        st.write("### Parsed Data")
        st.dataframe(df)

        # Generate data insights
        generate_insights(df)

        # Generate visualizations
        generate_visualizations(df)

    except Exception as e:
        st.error(f"An error occurred while processing the file: {e}")