import os
import streamlit as st
import pandas as pd
import mysql.connector
import plotly.express as px

st.set_page_config(page_title="Grievance Analytics", page_icon="📊", layout="wide")
st.title("Smart Government Grievance Management & Analytics")
st.caption("Educational portfolio prototype using synthetic sample data.")

@st.cache_resource
def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "GrievanceDB")
    )

try:
    conn = get_connection()
    df = pd.read_sql("""
        SELECT c.complaint_id, ci.citizen_name, ci.city,
               d.department_name, cc.category_name,
               o.officer_name, c.complaint_title, c.priority,
               c.status, c.complaint_date, c.resolution_date
        FROM Complaints c
        JOIN Citizens ci ON ci.citizen_id = c.citizen_id
        JOIN Departments d ON d.department_id = c.department_id
        JOIN Complaint_Categories cc ON cc.category_id = c.category_id
        LEFT JOIN Officers o ON o.officer_id = c.officer_id
    """, conn)
except Exception as exc:
    st.error("Could not connect to MySQL. Check that MySQL Server is running, the SQL scripts were executed, and environment variables are correct.")
    st.code(str(exc))
    st.stop()

if df.empty:
    st.info("No complaints found. Run sql/02_sample_data.sql first.")
    st.stop()

st.sidebar.header("Filters")
departments = sorted(df["department_name"].dropna().unique())
selected_depts = st.sidebar.multiselect("Department", departments, default=departments)
statuses = sorted(df["status"].dropna().unique())
selected_status = st.sidebar.multiselect("Status", statuses, default=statuses)
priorities = sorted(df["priority"].dropna().unique())
selected_priorities = st.sidebar.multiselect("Priority", priorities, default=priorities)

filtered = df[
    df["department_name"].isin(selected_depts)
    & df["status"].isin(selected_status)
    & df["priority"].isin(selected_priorities)
].copy()

total = len(filtered)
pending = int((filtered["status"] == "Pending").sum())
in_progress = int((filtered["status"] == "In Progress").sum())
resolved = int((filtered["status"] == "Resolved").sum())
resolution_rate = round((resolved / total) * 100, 1) if total else 0

c1, c2, c3, c4 = st.columns(4)
c1.metric("Total complaints", total)
c2.metric("Pending", pending)
c3.metric("In progress", in_progress)
c4.metric("Resolution rate", f"{resolution_rate}%")

left, right = st.columns(2)
with left:
    status_counts = filtered["status"].value_counts().rename_axis("Status").reset_index(name="Count")
    st.subheader("Complaints by status")
    st.plotly_chart(px.pie(status_counts, names="Status", values="Count", hole=0.45), use_container_width=True)

with right:
    dept_counts = filtered.groupby("department_name", as_index=False).size().rename(columns={"size": "complaints"})
    st.subheader("Department-wise workload")
    st.plotly_chart(px.bar(dept_counts, x="department_name", y="complaints", text="complaints"), use_container_width=True)

st.subheader("Complaint records")
search = st.text_input("Search by citizen, complaint title or city")
if search:
    mask = (
        filtered["citizen_name"].str.contains(search, case=False, na=False)
        | filtered["complaint_title"].str.contains(search, case=False, na=False)
        | filtered["city"].str.contains(search, case=False, na=False)
    )
    filtered = filtered[mask]

st.dataframe(filtered, use_container_width=True, hide_index=True)
st.download_button(
    "Download filtered report as CSV",
    data=filtered.to_csv(index=False).encode("utf-8"),
    file_name="grievance_report.csv",
    mime="text/csv"
)
