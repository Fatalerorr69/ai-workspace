"""
Správce studentských projektů - Project Manager

Modul pro řízení vzdělávacích projektů, sledování pokroku a generování reportů.
Používá se v rámci vzdělávacího IoT systému pro RPi 5.
"""

import json
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any
from enum import Enum


class TaskStatus(Enum):
    """Stavy úkolu v projektu"""
    ASSIGNED = "assigned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    BLOCKED = "blocked"


class ProjectStatus(Enum):
    """Stavy projektu"""
    PLANNED = "planned"
    ACTIVE = "active"
    COMPLETED = "completed"
    ARCHIVED = "archived"


class ProjectManager:
    """
    Třída pro řízení studentských projektů.
    
    Spravuje vytváření projektů, přidělování úkolů, sledování pokroku
    a generování reportů.
    
    Attributes:
        projects (Dict): Slovník všech projektů
        tasks (List): Seznam všech úkolů
        resources (List): Seznam dostupných zdrojů
        logger (logging.Logger): Logger pro auditování
    """
    
    def __init__(self, log_file: str = "/var/log/project-manager.log"):
        """
        Inicializace správce projektů.
        
        Args:
            log_file: Cesta k log souboru
        """
        self.projects: Dict[str, Dict[str, Any]] = {}
        self.tasks: List[Dict[str, Any]] = []
        self.resources: List[Dict[str, Any]] = []
        self.logger = self._setup_logging(log_file)
    
    def _setup_logging(self, log_file: str) -> logging.Logger:
        """Nastavení loggingu"""
        logger = logging.getLogger("ProjectManager")
        handler = logging.FileHandler(log_file)
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)
        return logger
    
    def create_project(
        self,
        name: str,
        description: str,
        objectives: List[str],
        timeline: str,
        created_by: str = "teacher"
    ) -> Dict[str, Any]:
        """
        Vytvoření nového projektu.
        
        Args:
            name: Název projektu
            description: Popis projektu
            objectives: Seznam cílů
            timeline: Časový plán (např. "4 týdny")
            created_by: Vytvořil (výchozí: teacher)
        
        Returns:
            Slovník s daty projektu
        
        Raises:
            ValueError: Pokud projekt s tímto názvem již existuje
        """
        if name in self.projects:
            self.logger.error(f"Projekt '{name}' již existuje")
            raise ValueError(f"Projekt '{name}' již existuje")
        
        project = {
            'name': name,
            'description': description,
            'objectives': objectives,
            'timeline': timeline,
            'status': ProjectStatus.PLANNED.value,
            'created_by': created_by,
            'created_at': datetime.now().isoformat(),
            'tasks': [],
            'resources': [],
            'milestones': [],
            'risks': []
        }
        
        self.projects[name] = project
        self.logger.info(f"Projekt '{name}' vytvořen uživatelem '{created_by}'")
        return project
    
    def add_task(
        self,
        project_name: str,
        task_name: str,
        assignee: str,
        deadline: str,
        description: str = "",
        priority: str = "normal"
    ) -> Optional[Dict[str, Any]]:
        """
        Přidání úkolu do projektu.
        
        Args:
            project_name: Název projektu
            task_name: Název úkolu
            assignee: Osoba, která má úkol na starosti
            deadline: Deadline (ISO format: YYYY-MM-DD)
            description: Popis úkolu
            priority: Priorita (low, normal, high, critical)
        
        Returns:
            Slovník s údaji úkolu nebo None
        
        Raises:
            ValueError: Pokud projekt neexistuje
        """
        if project_name not in self.projects:
            self.logger.error(f"Projekt '{project_name}' neexistuje")
            raise ValueError(f"Projekt '{project_name}' neexistuje")
        
        task = {
            'id': len(self.tasks) + 1,
            'name': task_name,
            'description': description,
            'assignee': assignee,
            'deadline': deadline,
            'priority': priority,
            'status': TaskStatus.ASSIGNED.value,
            'created_at': datetime.now().isoformat(),
            'dependencies': []
        }
        
        self.projects[project_name]['tasks'].append(task)
        self.tasks.append(task)
        self.logger.info(
            f"Úkol '{task_name}' přidán do projektu '{project_name}' "
            f"a přidělen uživateli '{assignee}'"
        )
        return task
    
    def update_task_status(
        self,
        task_id: int,
        new_status: str,
        notes: str = ""
    ) -> bool:
        """
        Aktualizace stavu úkolu.
        
        Args:
            task_id: ID úkolu
            new_status: Nový stav (assigned, in_progress, completed, blocked)
            notes: Poznámky k změně
        
        Returns:
            True pokud byla aktualizace úspěšná
        """
        for task in self.tasks:
            if task['id'] == task_id:
                old_status = task['status']
                task['status'] = new_status
                task['updated_at'] = datetime.now().isoformat()
                task['notes'] = notes
                self.logger.info(
                    f"Úkol {task_id}: '{old_status}' → '{new_status}' ({notes})"
                )
                return True
        
        self.logger.warning(f"Úkol s ID {task_id} nebyl nalezen")
        return False
    
    def track_progress(self, project_name: str) -> Optional[float]:
        """
        Sledování pokroku projektu (procento hotových úkolů).
        
        Args:
            project_name: Název projektu
        
        Returns:
            Procento hotových úkolů nebo None
        """
        if project_name not in self.projects:
            self.logger.error(f"Projekt '{project_name}' neexistuje")
            return None
        
        project = self.projects[project_name]
        tasks = project['tasks']
        
        if not tasks:
            return 0.0
        
        completed = sum(
            1 for task in tasks 
            if task['status'] == TaskStatus.COMPLETED.value
        )
        progress = (completed / len(tasks)) * 100
        
        self.logger.info(
            f"Projekt '{project_name}': {progress:.1f}% hotovo "
            f"({completed}/{len(tasks)} úkolů)"
        )
        return round(progress, 1)
    
    def generate_report(self, project_name: str) -> Optional[Dict[str, Any]]:
        """
        Generování podrobného reportu o projektu.
        
        Args:
            project_name: Název projektu
        
        Returns:
            Slovník s reportem nebo None
        """
        if project_name not in self.projects:
            self.logger.error(f"Projekt '{project_name}' neexistuje")
            return None
        
        project = self.projects[project_name]
        progress = self.track_progress(project_name)
        
        completed_tasks = [
            task['name'] for task in project['tasks']
            if task['status'] == TaskStatus.COMPLETED.value
        ]
        
        pending_tasks = [
            {
                'name': task['name'],
                'assignee': task['assignee'],
                'deadline': task['deadline'],
                'priority': task['priority'],
                'status': task['status']
            }
            for task in project['tasks']
            if task['status'] != TaskStatus.COMPLETED.value
        ]
        
        report = {
            'project_name': project_name,
            'status': project['status'],
            'progress': progress,
            'total_tasks': len(project['tasks']),
            'completed_tasks_count': len(completed_tasks),
            'completed_tasks': completed_tasks,
            'pending_tasks_count': len(pending_tasks),
            'pending_tasks': pending_tasks,
            'risks': project.get('risks', []),
            'objectives': project.get('objectives', []),
            'generated_at': datetime.now().isoformat()
        }
        
        self.logger.info(f"Report pro projekt '{project_name}' vygenerován")
        return report
    
    def export_project(self, project_name: str, filepath: str) -> bool:
        """
        Export projektu do JSON souboru.
        
        Args:
            project_name: Název projektu
            filepath: Cesta k souboru
        
        Returns:
            True pokud byl export úspěšný
        """
        if project_name not in self.projects:
            self.logger.error(f"Projekt '{project_name}' neexistuje")
            return False
        
        try:
            project = self.projects[project_name]
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(project, f, indent=2, ensure_ascii=False)
            self.logger.info(f"Projekt '{project_name}' exportován do '{filepath}'")
            return True
        except IOError as e:
            self.logger.error(f"Chyba při exportu projektu: {e}")
            return False
    
    def get_project_stats(self, project_name: str) -> Optional[Dict[str, Any]]:
        """
        Získání statistik projektu.
        
        Args:
            project_name: Název projektu
        
        Returns:
            Slovník se statistikami
        """
        if project_name not in self.projects:
            return None
        
        project = self.projects[project_name]
        tasks = project['tasks']
        
        stats = {
            'total_tasks': len(tasks),
            'completed': sum(1 for t in tasks if t['status'] == TaskStatus.COMPLETED.value),
            'in_progress': sum(1 for t in tasks if t['status'] == TaskStatus.IN_PROGRESS.value),
            'blocked': sum(1 for t in tasks if t['status'] == TaskStatus.BLOCKED.value),
            'assigned': sum(1 for t in tasks if t['status'] == TaskStatus.ASSIGNED.value),
            'by_priority': {
                'critical': sum(1 for t in tasks if t.get('priority') == 'critical'),
                'high': sum(1 for t in tasks if t.get('priority') == 'high'),
                'normal': sum(1 for t in tasks if t.get('priority') == 'normal'),
                'low': sum(1 for t in tasks if t.get('priority') == 'low'),
            }
        }
        
        return stats


# Příklad použití
if __name__ == "__main__":
    # Vytvořit instanci správce
    pm = ProjectManager()
    
    # Vytvořit projekt
    weather_project = pm.create_project(
        name="Weather Station IoT",
        description="Měření a vizualizace environmentálních dat",
        objectives=[
            "Sběr dat z teplotního čidla",
            "Vizuální zobrazení dat",
            "Analýza trendů"
        ],
        timeline="4 týdny",
        created_by="teacher"
    )
    
    # Přidat úkoly
    pm.add_task(
        project_name="Weather Station IoT",
        task_name="Připojení teplotního čidla",
        assignee="Jan Novák",
        deadline="2025-09-20",
        description="Připojit BME280 čidlo k RPi 5",
        priority="high"
    )
    
    pm.add_task(
        project_name="Weather Station IoT",
        task_name="Implementace webového rozhraní",
        assignee="Marie Svobodová",
        deadline="2025-09-27",
        description="Vytvořit web UI pro zobrazení dat",
        priority="high"
    )
    
    # Sledovat pokrok
    progress = pm.track_progress("Weather Station IoT")
    print(f"Pokrok projektu: {progress}%")
    
    # Generovat report
    report = pm.generate_report("Weather Station IoT")
    if report:
        print(f"\nReport projektu '{report['project_name']}':")
        print(f"Cílový stav: {report['status']}")
        print(f"Pokrok: {report['progress']}%")
        print(f"Hotových úkolů: {report['completed_tasks_count']}/{report['total_tasks']}")
