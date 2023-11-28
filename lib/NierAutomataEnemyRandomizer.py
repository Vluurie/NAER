from datetime import datetime, timedelta
import json
import os
import re
import shutil
import sys
import subprocess
import tempfile
from PyQt5.QtWidgets import (QApplication, QWidget, QLabel, QVBoxLayout, QPushButton, 
                             QFileDialog, QTextEdit, QGridLayout, QScrollArea, QHBoxLayout, QGraphicsDropShadowEffect, QCheckBox, QGroupBox, QMessageBox)
from PyQt5.QtGui import QPixmap, QFont, QColor
from PyQt5.QtCore import QThread, pyqtSignal, Qt

class DartScriptThread(QThread):
    update_log = pyqtSignal(str)

    def __init__(self, script_path, input, specialDatOutputPath, tempFilePath, categories, ignore_list_arg):
        super().__init__()
        self.script_path = script_path
        self.input = input
        self.specialDatOutputPath = specialDatOutputPath
        self.tempFilePath = tempFilePath
        self.categories = categories
        self.ignore_list_arg = ignore_list_arg

    def run(self):
        process = subprocess.Popen(
            ["dart", self.script_path, self.input, "-o", self.specialDatOutputPath, self.tempFilePath] + self.categories + [self.ignore_list_arg],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

        for line in process.stdout:
            self.update_log.emit(line)

class EnemyRandomizerApp(QWidget):


    def __init__(self):
        super().__init__()
        self.createdFolders = []
        self.selectedImages = []
        self.initUI()

    def initUI(self):
        self.setWindowTitle('NAER')
        self.setGeometry(300, 300, 1000, 1200)
        self.setFont(QFont("Arial", 10))
        self.setObjectName("mainWindow")
        self.setStyleSheet("""
            #mainWindow { 
                background-color: turkey;
                background-repeat: no-repeat;
                background-position: center;
            }
            QWidget { 
                background-color: rgba(245, 245, 245, 0.8);
                color: #333;
            }
            QPushButton {
                background-color: #007bff;
                color: white;
                border-radius: 4px;
                padding: 6px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #0056b3;
            }
            QPushButton#undoButton {
                background-color: #ff6347; /* Tomato color */
                color: white;
                border-radius: 4px;
                padding: 6px;
                font-weight: bold;
            }
            QPushButton#undoButton:hover {
                background-color: #ff4500; /* OrangeRed color */
            }
            QLabel, QLineEdit, QTextEdit {
                border: 1px solid #ddd;
                padding: 4px;
            }
            QTextEdit {
                background-color: black;
                color: white;
                font-family: 'Courier New';
            }
            QLabel#title {
                font-size: 20px;
                font-weight: bold;
            }
            QGroupBox {
                font-size: 14px;
                font-weight: bold;
            }
        """)

        mainLayout = QVBoxLayout(self)
        self.setupLogo(mainLayout)
        self.setupDirectorySelection(mainLayout)
        self.setupImageGrid(mainLayout)
        self.setupLogOutput(mainLayout)
        self.setupButtons(mainLayout)
        self.setupCategorySelection(mainLayout)

    def setupButtons(self, layout):
        # Horizontal layout for buttons
        buttonLayout = QHBoxLayout()

        # Unselect All Button
        self.unselectAllButton = QPushButton('Unselect All Enemies', self)
        self.unselectAllButton.clicked.connect(self.unselectAllImages)
        buttonLayout.addWidget(self.unselectAllButton)

        # Start Button
        self.startButton = QPushButton('Start Randomizing', self)
        self.startButton.clicked.connect(self.startRandomizing)
        buttonLayout.addWidget(self.startButton)

        # Undo Button
        self.undoButton = QPushButton('Undo Last Randomization', self)
        self.undoButton.setObjectName("undoButton")
        self.undoButton.clicked.connect(self.undoLastRandomization)
        buttonLayout.addWidget(self.undoButton)

        layout.addLayout(buttonLayout)
        

    def undoLastRandomization(self):
        reply = QMessageBox.question(self, 'Confirm Undo', 
                                     "Are you sure you want to undo the last randomization?",
                                     QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
        if reply == QMessageBox.Yes:
            try:
                for folder in self.createdFolders:
                    full_path = os.path.normpath(os.path.join(self.specialDatOutputPath, folder))

                    if os.path.isdir(full_path):
                        shutil.rmtree(full_path)  # Removes directory and all its contents
                    elif os.path.isfile(full_path):
                        os.remove(full_path)  # Removes a single file

                QMessageBox.information(self, "Undo Successful", "Last randomization has been undone.", QMessageBox.Ok)
                self.createdFolders.clear()  # Clear the list after undoing
            except Exception as e:
                QMessageBox.warning(self, "Undo Failed", str(e), QMessageBox.Ok)
        else:
            print("Undo cancelled.")

    def unselectAllImages(self):
        self.selectedImages.clear()
        self.updateImageGridSelections()
        self.selectedImagesLabel.setText("Info:\n\nYour Input Directory is the path with ur .cpk files /SteamLibrary/steamapps/common/NieRAutomata/data or a copy of them (data002.cpk, data012.cpk, data100.cpk).\nYour Output Directory must be your data folder /SteamLibrary/steamapps/common/NieRAutomata/data. \n\nSelected Enemies: 0 \n\nNote: by selecting an enemy, all enemies ingame will be changed to only this type of enemies.\nBy selecting no enemy and pressing directly 'Start Randomizing', all enemies will be used for randomizing.")

    def updateImageGridSelections(self):
        for i in range(self.imageGridLayout.count()):
            widget = self.imageGridLayout.itemAt(i).widget()
            if isinstance(widget, QLabel):
                self.unmarkImage(widget)

    def setupLogo(self, layout):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        folder_path = os.path.join(script_dir, 'logomyy.png')
        self.logo = QLabel(self)
        pixmap = QPixmap(folder_path)
        self.logo.setPixmap(pixmap.scaled(400, 200, Qt.KeepAspectRatio))
        self.logo.setAlignment(Qt.AlignCenter)
        layout.addWidget(self.logo)

    def setupDirectorySelection(self, layout):
        directoryLayout = QHBoxLayout()
        self.inputLabel = QLabel("Input Directory:")
        self.inputButton = QPushButton('Browse', self)
        self.outputLabel = QLabel("Output Directory:")
        self.outputButton = QPushButton('Browse', self)
        directoryLayout.addWidget(self.inputLabel)
        directoryLayout.addWidget(self.inputButton)
        directoryLayout.addWidget(self.outputLabel)
        directoryLayout.addWidget(self.outputButton)
        self.inputButton.clicked.connect(self.openInputFileDialog)
        self.outputButton.clicked.connect(self.openOutputFileDialog)
        layout.addLayout(directoryLayout)


    def setupImageGrid(self, layout):

        script_dir = os.path.dirname(os.path.abspath(__file__))
        folder_path = os.path.join(script_dir, 'enemys')
        self.selectedImagesLabel = QLabel("Info:\n\nYour Input Directory is the path with ur .cpk files /SteamLibrary/steamapps/common/NieRAutomata/data or a copy of them (data002.cpk, data012.cpk, data100.cpk).\nYour Output Directory must be your data folder /SteamLibrary/steamapps/common/NieRAutomata/data. \n\nSelected Enemies: 0 \n\nNote: by selecting an enemy, all enemies ingame will be changed to only this type of enemies.\nBy selecting no enemy and pressing directly 'Start Randomizing', all enemies will be used for randomizing.")
        layout.addWidget(self.selectedImagesLabel)
        self.scrollArea = QScrollArea(self)
        self.scrollArea.setWidgetResizable(True)
        self.imageGridLayout = QGridLayout()
        self.scrollAreaWidgetContents = QWidget()
        self.scrollAreaWidgetContents.setLayout(self.imageGridLayout)
        self.scrollArea.setWidget(self.scrollAreaWidgetContents)
        layout.addWidget(self.scrollArea)
        self.populateImageGrid(folder_path)

    def setupLogOutput(self, layout):
        self.logOutput = QTextEdit(self)
        self.logOutput.setReadOnly(True)
        self.logOutput.setPlaceholderText("Log output will appear here...")
        layout.addWidget(self.logOutput)

    def setupStartButton(self, layout):
        self.startButton = QPushButton('Start Randomizing', self)
        self.startButton.clicked.connect(self.startRandomizing)
        layout.addWidget(self.startButton)

    def openInputFileDialog(self):
        dir_path = QFileDialog.getExistingDirectory(self, "Select Input Directory")
        if dir_path:
            self.inputLabel.setText(f"Input Directory: {dir_path}")
            self.input = dir_path

    def openOutputFileDialog(self):
        dir_path = QFileDialog.getExistingDirectory(self, "Select Output Directory")
        if dir_path:
            self.outputLabel.setText(f"Output Directory: {dir_path}")
            self.specialDatOutputPath = dir_path
            mod_files = self.find_mod_files(dir_path)

            if mod_files:
                self.show_mods_message(mod_files)
            else:
                QMessageBox.information(self, "No Mod Files", "No mod files were found in the selected directory.", QMessageBox.Ok)

    def show_mods_message(self, mod_files):
        msg = QMessageBox()
        msg.setIcon(QMessageBox.Information)
        msg.setWindowTitle("Mod Files Detected, this mod's will be ignored on Randomization")
        msg.setStandardButtons(QMessageBox.Ok)
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFixedHeight(200) 
        scroll.setFixedWidth(400)
        widget = QWidget()
        layout = QVBoxLayout()

        for mod_file in mod_files:
            label = QLabel(mod_file)
            layout.addWidget(label)

        layout.addStretch()
        widget.setLayout(layout)
        scroll.setWidget(widget)
        msg_layout = msg.layout()
        msg_layout.addWidget(scroll, 0, 0, 1, msg_layout.columnCount())
        msg.exec_()

    def readEnemyData(self):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        folder_path = os.path.join(script_dir, 'sorted_enemy.dart')
        enemyGroups = {"Ground": [], "Fly": [], "Delete": []}
        with open(folder_path, 'r') as file:
            data = file.read()
            matches = re.findall(r'"(\w+)": \[(.*?)\]', data, re.DOTALL)
            for group, enemies in matches:
                enemyGroups[group] = [enemy.strip().strip('"') for enemy in enemies.split(',')]

        return enemyGroups

    def sortSelectedEnemies(self):
        enemyGroups = self.readEnemyData()
        sortedSelection = {"Ground": [], "Fly": [], "Delete": enemyGroups["Delete"]}
        for enemy in self.selectedImages:
            for group in ["Ground", "Fly"]:
                if enemy in enemyGroups[group]:
                    sortedSelection[group].append(enemy)
                    break

        return sortedSelection

    def startRandomizing(self):
        if hasattr(self, 'input') and hasattr(self, 'specialDatOutputPath'):
            if self.selectedImages:
                sortedEnemies = self.sortSelectedEnemies()
                with tempfile.NamedTemporaryFile(delete=False, mode='w', suffix='.dart') as tmp:
                    tmp.write("const Map<String, List<String>> sortedEnemyData = {\n")
                    for group, enemies in sortedEnemies.items():
                        enemies_formatted = ', '.join(f'"{enemy}"' for enemy in enemies)
                        tmp.write(f'  "{group}": [{enemies_formatted}],\n')
                    tmp.write("};\n")
                    tempFilePath = tmp.name
                    print(f"Temporary file created at: {tempFilePath}")
            else:
                tempFilePath = "ALL"

            categories = [cat for cat, checkBox in self.categories.items() if checkBox.isChecked()]
            categories_args = [f"--{cat.replace(' ', '').lower()}" for cat in categories] 
            mod_files = self.find_mod_files(self.specialDatOutputPath)
            ignore_list_arg = '--ignore=' + ','.join(mod_files)
            self.startButton.setEnabled(False)
            self.startButton.setText("Randomizing...")
            self.save_pre_randomization_time()
            folder_path = os.path.join('..\\bin\\nier_cli.dart')
            self.thread = DartScriptThread(folder_path, self.input, self.specialDatOutputPath, tempFilePath, categories_args, ignore_list_arg)
            self.thread.update_log.connect(self.updateLog)
            self.thread.start()
        else:
            self.logOutput.setText("Please select both input and output directories.")


    def save_pre_randomization_time(self):
        buffer_time = timedelta(minutes=60)
        pre_randomization_time = (datetime.now() - buffer_time).strftime('%Y-%m-%d %H:%M:%S')
        with open('pre_randomization_time.json', 'w') as file:
            json.dump({'pre_randomization_time': pre_randomization_time}, file)
   
    def find_mod_files(self, output_directory):
        mod_files = []

        # Load the pre-randomization time
        if os.path.exists('pre_randomization_time.json'):
            with open('pre_randomization_time.json', 'r') as file:
                pre_randomization_data = json.load(file)
                pre_randomization_time = datetime.strptime(pre_randomization_data['pre_randomization_time'], '%Y-%m-%d %H:%M:%S')
        else:
            pre_randomization_time = datetime.now()

        for root, dirs, files in os.walk(output_directory):
            for file in files:
                if file.endswith('.dat'):
                    file_path = os.path.join(root, file)
                    file_mod_time = datetime.fromtimestamp(os.path.getmtime(file_path))
                    if file_mod_time < pre_randomization_time:
                        mod_files.append(file)

        return mod_files

    def save_last_randomization_time(self):
        last_randomization_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        with open('last_randomization_time.json', 'w') as file:
            json.dump({'last_randomization_time': last_randomization_time}, file)

    def updateLog(self, log):
        self.logOutput.append(log)
        if "Folder created:" in log:
            folder_name = log.split("Folder created:")[-1].strip()
            self.createdFolders.append(folder_name)
        elif "Randomizing complete" in log:
            self.startButton.setEnabled(True)
            self.startButton.setText("Start Randomizing")
            self.showCompletionMessage()


    def showCompletionMessage(self):
        msgBox = QMessageBox()
        msgBox.setIcon(QMessageBox.Information)
        msgBox.setText("Randomization process completed successfully.")
        msgBox.setWindowTitle("Randomization Complete")
        self.save_last_randomization_time()
        msgBox.setStandardButtons(QMessageBox.Ok)
        msgBox.exec_()

    def createClickableImage(self, image_path):
        label = QLabel(self)
        pixmap = QPixmap(image_path)
        label.setPixmap(pixmap.scaled(200, 200, Qt.KeepAspectRatio))
        base_name = os.path.splitext(os.path.basename(image_path))[0]
        label.mousePressEvent = lambda event, name=base_name: self.onImageClick(event, name, label)
        return label

    def populateImageGrid(self, folder_path):
        for i, image_file in enumerate(os.listdir(folder_path)):
            if image_file.endswith('.png'):
                label = self.createClickableImage(os.path.join(folder_path, image_file))
                self.imageGridLayout.addWidget(label, i // 4, i % 4)

    def onImageClick(self, event, image_name, label):
        if image_name not in self.selectedImages:
            self.selectedImages.append(image_name)
            self.markImageAsSelected(label)
        else:
            self.selectedImages.remove(image_name)
            self.unmarkImage(label)
        self.selectedImagesLabel.setText(f"Info:\n\nYour Input Directory is the path with ur .cpk files /SteamLibrary/steamapps/common/NieRAutomata/data or a copy of them (data002.cpk, data012.cpk, data100.cpk).\nYour Output Directory must be your data folder /SteamLibrary/steamapps/common/NieRAutomata/data. \n\nSelected Enemies: {len(self.selectedImages)}\n\nNote: by selecting an enemy, all enemies ingame will be changed to only this type of enemies.\nBy selecting no enemy and pressing directly 'Start Randomizing', all enemies will be used for randomizing.")
        print(f"Selected Enemies: {self.selectedImages}")

    def markImageAsSelected(self, label):
        shadow = QGraphicsDropShadowEffect()
        shadow.setBlurRadius(15) 
        shadow.setColor(QColor(94, 151, 246)) 
        shadow.setOffset(0)
        label.setGraphicsEffect(shadow)
        label.setStyleSheet("""
            QLabel {
                background-color: yellow;
                border: 2px solid #5e97f6; /* Blue border */
                border-radius: 5px; /* Rounded corners */
                padding: 2px;
                margin: 2px;
            }
        """)

    def unmarkImage(self, label):
        label.setStyleSheet("")

    def setupCategorySelection(self, layout):
        self.categoryGroupBox = QGroupBox("Select Categories for Randomization")
        categoryLayout = QVBoxLayout()

        # Define categories
        self.categories = {
            "All Quests": QCheckBox("All Quests"),
            "All Maps": QCheckBox("All Maps"),
            "All Phases": QCheckBox("All Phases")
        }

        for category, checkBox in self.categories.items():
            categoryLayout.addWidget(checkBox)
            checkBox.setChecked(True)

        self.categoryGroupBox.setLayout(categoryLayout)
        layout.addWidget(self.categoryGroupBox)
          
def main():
    app = QApplication(sys.argv)
    app.setStyle('QtCurve')
    ex = EnemyRandomizerApp()
    ex.show()
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()
