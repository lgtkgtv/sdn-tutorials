chmod +x *.sh
./setup-sdn-tutorial.sh
./test-sdn-tutorial.sh
./cleanup-tutorial.sh
./quick-cleanup.sh

export PROJECT_ROOT=$(pwd)
export PROJECT_NAME=my-sdn-project

cd $PROJECT_ROOT/$PROJECT_NAME
source activate.sh
make help

==========

# 1. Navigate to your preferred directory
cd /path/to/your/projects

# 2. Optional: Set environment variables
export PROJECT_ROOT=$(pwd)
export PROJECT_NAME=my-sdn-project

# 3. Create and run setup script
cat > setup-sdn-tutorial.sh << 'EOF'
[COPY THE ENHANCED SETUP SCRIPT CONTENT FROM ABOVE]
EOF
chmod +x setup-sdn-tutorial.sh
./setup-sdn-tutorial.sh

# 4. Create and run test script  
cat > test-sdn-tutorial.sh << 'EOF'
[COPY THE ENHANCED TEST SCRIPT CONTENT FROM ABOVE]
EOF
chmod +x test-sdn-tutorial.sh
./test-sdn-tutorial.sh

# 5. Create cleanup scripts
cat > cleanup-tutorial.sh << 'EOF'
[COPY THE INTERACTIVE CLEANUP SCRIPT CONTENT FROM ABOVE]
EOF

cat > quick-cleanup.sh << 'EOF'
[COPY THE QUICK CLEANUP SCRIPT CONTENT FROM ABOVE]  
EOF

chmod +x cleanup-tutorial.sh quick-cleanup.sh

# 6. Use the professional workflow
cd $PROJECT_ROOT/$PROJECT_NAME
source activate.sh
make help  # See all available commands