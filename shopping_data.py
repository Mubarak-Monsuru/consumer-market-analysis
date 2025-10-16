import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os
import psycopg2

data = "data/shopping_behavior_updated.csv"
df = pd.read_csv(data)
# print(df.head())
# print(df.columns)
# print(df.dtypes)
# print(df.isna().sum())
# print(df[df.duplicated()])

df.columns = df.columns.str.lower().str.replace(' ', '_')

# Convert column "listing_id" to string data type
df['customer_id'] = df['customer_id'].astype('str')
assert df['customer_id'].dtype == 'object'

# Observe unique values in categorical and object columns
df_categorical = df.select_dtypes(include=['object', 'category'])
for column in df_categorical:
    print(f'{column} : {df[column].unique()}')

# Get summary statistics of numerical columns
df.describe()

# Create rating category from review rating column
bins = [0, 2.0, 3.0, 4.0, 4.4, 5.0]
labels = ['Poor', 'Average', 'Good', 'Very Good', 'Excellent']
df['rating_category'] = pd.cut(df['review_rating'], bins=bins, labels=labels)

# Create age group from age column
bins = [17, 20, 30, 50, 70]
labels = ['Young', 'Young Adult', 'Adult', 'Old']
df['age_group'] = pd.cut(df['age'], bins=bins, labels=labels)

print(df.head())
print(df.columns)

load_dotenv()
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

# Create SQLAlchemy engine
engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

print(DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME)

# Upload to database (this will create or replace the table automatically)
try:
    df.to_sql("customer_behavior", engine, schema="shopping_data", if_exists="replace", index=False)
    print("✅ Data uploaded successfully to 'customer_behavior' table!")
except Exception as e:
    print(f"❌ Upload failed: {e}")

# Query the uploaded table to verify
try:
    with engine.connect() as connection:
        result = connection.execute(text("SELECT * FROM shopping_data.customer_behavior LIMIT 5;"))
        for row in result:
            print(row)
except Exception as e:
    print(f"❌ Error querying data: {e}")