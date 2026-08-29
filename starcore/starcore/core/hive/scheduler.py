from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.interval import IntervalTrigger
from apscheduler.triggers.cron import CronTrigger
from typing import Dict, List
from core.logging import logger

class Scheduler:
    def __init__(self):
        self.scheduler = BackgroundScheduler()
        self.jobs = {}
        logger.info("Scheduler initialized")

    def start(self):
        try:
            if not self.scheduler.running:
                self.scheduler.start()
                logger.info("Scheduler started")
            else:
                logger.info("Scheduler already running")
        except Exception as e:
            logger.error(f"Scheduler start error: {e}")

    def add_interval_job(self, name: str, func, interval_seconds: int, args=None, kwargs=None):
        if args is None: args = []
        if kwargs is None: kwargs = {}
        job = self.scheduler.add_job(
            func,
            trigger=IntervalTrigger(seconds=interval_seconds),
            args=args,
            kwargs=kwargs,
            id=name,
            replace_existing=True
        )
        self.jobs[name] = job
        logger.info(f"Scheduled interval job {name} every {interval_seconds}s")
        return job

    def add_cron_job(self, name: str, func, cron_expr: str, args=None, kwargs=None):
        if args is None: args = []
        if kwargs is None: kwargs = {}
        job = self.scheduler.add_job(
            func,
            trigger=CronTrigger.from_crontab(cron_expr),
            args=args,
            kwargs=kwargs,
            id=name,
            replace_existing=True
        )
        self.jobs[name] = job
        logger.info(f"Scheduled cron job {name}: {cron_expr}")
        return job

    def remove_job(self, name: str):
        if name in self.jobs:
            self.jobs[name].remove()
            del self.jobs[name]
            logger.info(f"Removed job {name}")

    def status(self) -> Dict:
        return {
            "running": self.scheduler.running,
            "jobs": list(self.jobs.keys())
        }

    def shutdown(self):
        if self.scheduler.running:
            self.scheduler.shutdown(wait=False)
        logger.info("Scheduler shutdown")
