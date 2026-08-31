"""
Unit testy pro ProjectManager

Testuje všechny kritické funkce správce projektů.
"""

import unittest
import json
import tempfile
import os
from pathlib import Path
from src.python.project_manager import ProjectManager, TaskStatus, ProjectStatus


class TestProjectManager(unittest.TestCase):
    """Testy pro ProjectManager třídu"""
    
    def setUp(self):
        """Příprava testu - vytvoření temp log souboru"""
        self.temp_log = tempfile.NamedTemporaryFile(delete=False, suffix='.log')
        self.pm = ProjectManager(self.temp_log.name)
    
    def tearDown(self):
        """Čistka po testech"""
        if os.path.exists(self.temp_log.name):
            os.unlink(self.temp_log.name)
    
    def test_create_project(self):
        """Test vytvoření projektu"""
        project = self.pm.create_project(
            name="Test Project",
            description="Test Description",
            objectives=["Obj1", "Obj2"],
            timeline="2 weeks"
        )
        
        self.assertIsNotNone(project)
        self.assertEqual(project['name'], "Test Project")
        self.assertEqual(project['status'], ProjectStatus.PLANNED.value)
    
    def test_duplicate_project_raises_error(self):
        """Test že duplikátní projekt vyvede chybu"""
        self.pm.create_project(
            name="Test Project",
            description="Test",
            objectives=[],
            timeline="1 week"
        )
        
        with self.assertRaises(ValueError):
            self.pm.create_project(
                name="Test Project",
                description="Test",
                objectives=[],
                timeline="1 week"
            )
    
    def test_add_task(self):
        """Test přidání úkolu do projektu"""
        self.pm.create_project(
            name="Project A",
            description="Test",
            objectives=[],
            timeline="1 week"
        )
        
        task = self.pm.add_task(
            project_name="Project A",
            task_name="Task 1",
            assignee="John Doe",
            deadline="2025-12-31"
        )
        
        self.assertIsNotNone(task)
        self.assertEqual(task['name'], "Task 1")
        self.assertEqual(task['status'], TaskStatus.ASSIGNED.value)
    
    def test_track_progress(self):
        """Test sledování pokroku projektu"""
        self.pm.create_project(
            name="Project B",
            description="Test",
            objectives=[],
            timeline="1 week"
        )
        
        # Přidat úkoly
        for i in range(3):
            self.pm.add_task(
                project_name="Project B",
                task_name=f"Task {i}",
                assignee="Student",
                deadline="2025-12-31"
            )
        
        # Počáteční pokrok - 0%
        progress = self.pm.track_progress("Project B")
        self.assertEqual(progress, 0.0)
        
        # Označit jeden úkol za hotový
        self.pm.update_task_status(1, TaskStatus.COMPLETED.value)
        progress = self.pm.track_progress("Project B")
        self.assertAlmostEqual(progress, 33.3, places=1)
    
    def test_generate_report(self):
        """Test generování reportu"""
        self.pm.create_project(
            name="Project C",
            description="Test Project",
            objectives=["Learn", "Build"],
            timeline="3 weeks"
        )
        
        self.pm.add_task(
            project_name="Project C",
            task_name="Task 1",
            assignee="Alice",
            deadline="2025-12-15"
        )
        
        report = self.pm.generate_report("Project C")
        
        self.assertIsNotNone(report)
        self.assertEqual(report['project_name'], "Project C")
        self.assertEqual(report['total_tasks'], 1)
        self.assertEqual(report['completed_tasks_count'], 0)
        self.assertEqual(len(report['pending_tasks']), 1)
    
    def test_export_project(self):
        """Test exportu projektu do JSON"""
        self.pm.create_project(
            name="Project D",
            description="Export Test",
            objectives=[],
            timeline="1 week"
        )
        
        with tempfile.NamedTemporaryFile(
            mode='w', delete=False, suffix='.json'
        ) as f:
            export_file = f.name
        
        try:
            success = self.pm.export_project("Project D", export_file)
            self.assertTrue(success)
            
            # Kontrola že soubor existuje a je validní JSON
            self.assertTrue(os.path.exists(export_file))
            with open(export_file, 'r') as f:
                data = json.load(f)
                self.assertEqual(data['name'], "Project D")
        
        finally:
            if os.path.exists(export_file):
                os.unlink(export_file)
    
    def test_get_project_stats(self):
        """Test získání statistik projektu"""
        self.pm.create_project(
            name="Project E",
            description="Stats Test",
            objectives=[],
            timeline="1 week"
        )
        
        # Přidat úkoly s různými prioritami
        self.pm.add_task(
            project_name="Project E",
            task_name="Critical Task",
            assignee="Dev1",
            deadline="2025-12-15",
            priority="critical"
        )
        
        self.pm.add_task(
            project_name="Project E",
            task_name="Normal Task",
            assignee="Dev2",
            deadline="2025-12-20",
            priority="normal"
        )
        
        stats = self.pm.get_project_stats("Project E")
        
        self.assertIsNotNone(stats)
        self.assertEqual(stats['total_tasks'], 2)
        self.assertEqual(stats['by_priority']['critical'], 1)
        self.assertEqual(stats['by_priority']['normal'], 1)


class TestTaskStatus(unittest.TestCase):
    """Testy pro TaskStatus enum"""
    
    def test_task_status_values(self):
        """Test že TaskStatus má všechny požadované stavy"""
        self.assertIn('assigned', [s.value for s in TaskStatus])
        self.assertIn('in_progress', [s.value for s in TaskStatus])
        self.assertIn('completed', [s.value for s in TaskStatus])
        self.assertIn('blocked', [s.value for s in TaskStatus])


class TestProjectStatus(unittest.TestCase):
    """Testy pro ProjectStatus enum"""
    
    def test_project_status_values(self):
        """Test že ProjectStatus má všechny požadované stavy"""
        self.assertIn('planned', [s.value for s in ProjectStatus])
        self.assertIn('active', [s.value for s in ProjectStatus])
        self.assertIn('completed', [s.value for s in ProjectStatus])
        self.assertIn('archived', [s.value for s in ProjectStatus])


if __name__ == '__main__':
    unittest.main()
