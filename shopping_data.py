import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Extract & Transform Function
def extract_transform(file_path):
    """
    Load, clean, and preprocess dataset.
    """
    df = pd.read_csv(file_path)

    # Standardize column names
    df.columns = df.columns.str.lower().str.replace(' ', '_')

    print("Data extracted and transformed successfully!")
    return df

# Feature Engineering Function
def feature_engineering(df: pd.DataFrame):
    """
    Add new features (rating category and age group).
    """
    # Rating category
    rating_bins = [0, 2.0, 3.0, 4.0, 4.4, 5.0]
    rating_labels = ['Poor', 'Average', 'Good', 'Very Good', 'Excellent']
    df['rating_category'] = pd.cut(df['review_rating'], bins=rating_bins, labels=rating_labels)

    # Age group
    age_bins = [17, 20, 30, 50, 70]
    age_labels = ['Young', 'Young Adult', 'Adult', 'Old']
    df['age_group'] = pd.cut(df['age'], bins=age_bins, labels=age_labels)

    print("Feature engineering completed successfully!")
    return df

# Load Function
def load_to_postgres(df: pd.DataFrame, table_name: str, schema_name: str = "shopping_data"):
    """
    Load DataFrame into PostgreSQL table.
    """
    load_dotenv()

    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = os.getenv("DB_PORT")
    DB_NAME = os.getenv("DB_NAME")

    engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

    try:
        df.to_sql(table_name, engine, schema=schema_name, if_exists="replace", index=False)
        print(f"Data uploaded successfully to '{schema_name}.{table_name}' table!")
    except Exception as e:
        print(f"Upload failed: {e}")
        return

    # Verify upload
    try:
        with engine.connect() as connection:
            result = connection.execute(text(f"SELECT * FROM {schema_name}.{table_name} LIMIT 5;"))
            print("Sample data from uploaded table:")
            for row in result:
                print(row)
    except Exception as e:
        print(f"Error querying data: {e}")


# Run the ETL Pipeline
if __name__ == "__main__":
    data_path = "data/shopping_behavior_updated.csv"

    # ETL Pipeline Steps
    df = extract_transform(data_path)
    df = feature_engineering(df)
    load_to_postgres(df, table_name="customer_behavior")
