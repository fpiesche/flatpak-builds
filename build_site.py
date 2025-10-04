#!/usr/bin/env python3

from argparse import ArgumentParser
import glob
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from jinja2 import Environment, FileSystemLoader, StrictUndefined
import json
from lxml import etree
from pathlib import Path
import re
import subprocess


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, Path(__file__).parent, **kwargs)


def inotify_filter(filename: str, watcher, boolean) -> bool:
    excludes = [
        ".flatpak-builder",
        "^build$",
        ".git",
        "shared-modules",
        ".*.html$",
        ".*.flatpakrepo$"
    ]
    for pattern in excludes:
        if re.match(pattern, filename):
            return False
    else:
        return True


def parse_app(app_id: str) -> dict:
    base_app_path = Path("apps") / app_id
    flathub_status = "Pending submission"
    flathub_id = None
    is_graduate = False
    try:
        with open(base_app_path / "flathub.json", "r") as flathub_json_fileobj:
            flathub_json = json.loads(flathub_json_fileobj.read())
        if "end-of-life-rebase" in flathub_json.keys():
            flathub_status = flathub_json["end-of-life"]
            flathub_id = flathub_json["end-of-life-rebase"]
            is_graduate = True
        elif "_submission-status" in flathub_json.keys():
            flathub_status = flathub_json["_submission-status"]
    except:
        pass
    metainfo = etree.parse(base_app_path / f"{app_id}.metainfo.xml").getroot()

    app_info = {
        "id": app_id,
        "name": metainfo.xpath("name")[0].text,
        "summary": metainfo.xpath("summary")[0].text,
        "description": etree.tostring(metainfo.xpath("description")[0], encoding="unicode"),
        "flathub_status": flathub_status,
        "flathub_id": flathub_id,
        "flathub_url": f"https://flathub.org/apps/{flathub_id}" if "Flathub" in flathub_status else f"/apps/{flathub_id}.html",
        "developer_name": metainfo.xpath("developer/name")[0].text,
        "developer_url": metainfo.xpath("developer/url")[0].text,
        "developer_name": metainfo.xpath("developer/name")[0].text,
        "homepage_url": metainfo.xpath('url[@type="homepage"]')[0].text,
        "icon_url": f"https://cdn.jsdelivr.net/gh/fpiesche/flatpak-builds/apps/{app_id}/{app_id}",
        "listing_path": f"{base_app_path}.html",
        "install_url": f"appstream://{app_id}",
        "is_graduate": is_graduate,
        "screenshots": []
    }

    # Fill in correct image extension
    for image_extension in ["svg", "png"]:
        if (base_app_path / f"{app_id}.{image_extension}").exists():
            app_info["icon_url"] += f".{image_extension}"
            break

    for screenshot in metainfo.xpath("//screenshot"):
        app_info["screenshots"].append(
            {
                "image": screenshot.xpath("image")[0].text,
                "caption": screenshot.xpath("caption")[0].text,
                "type": screenshot.xpath("concat(@type, substring('none', 1 div not(@type)))")
            }
        )

    return app_info


def read_apps() -> list[dict]:
    for app in glob.glob("apps/*"):
        app_id = app.replace("apps/", "")
        if app_id == "shared-modules":
            continue
        app_spec = parse_app(app_id)
        yield app_spec


def generate_flatpakrepo():
    print("Generating .flatpakrepo file...")
    env = Environment(loader=FileSystemLoader("_templates"), undefined=StrictUndefined)
    template = env.get_template("ykc.flatpakrepo.j2")
    with open("_site/ykc.gpg", "r") as pubkey_file:
        gpgkey = pubkey_file.read()
    return template.render({"gpg_key": gpgkey})


def generate_index(apps: list[dict]) -> str:
    print("Writing main index...")
    env = Environment(loader=FileSystemLoader("_templates"), undefined=StrictUndefined)
    template = env.get_template("index.html.j2")
    return template.render({"apps": apps})


def generate_listing(app: dict) -> str:
    print(f"Writing listing html for {app['id']}...")
    env = Environment(loader=FileSystemLoader("_templates"), undefined=StrictUndefined)
    template = env.get_template("app_listing.html.j2")
    return template.render({"app": app})


def build_site(root: str):
    print("Building site...")
    root_path = Path(root)

    with open(root_path /"index.html", "w") as index_file:
        index_file.write(generate_index(list(read_apps())))
    
    apps_path = root_path / "apps"
    apps_path.mkdir(exist_ok=True)
    for app in read_apps():
        if not app["is_graduate"]:
            with open(apps_path / f"{app['id']}.html", "w") as listing_file:
                listing_file.write(generate_listing(app))

    with open(root_path / "ykc.flatpakrepo", "w") as repo_file:
        repo_file.write(generate_flatpakrepo())


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("-s", "--serve", action="store_true", help="Start http server after build")
    parser.add_argument("output_root", help="Root output directory")
    args = parser.parse_args()

    build_site(root=args.output_root)
    root_dir = Path(__file__).parent

    if args.serve:
        print(f"Monitoring {root_dir} for changes...")
        from inotifyrecursive import INotify, flags
        inotify = INotify()
        watch_flags = flags.CREATE | flags.DELETE | flags.MODIFY | flags.DELETE_SELF
        try:
            server = subprocess.Popen(["python", "-m", "http.server", "-d", args.output_root])
            wd = inotify.add_watch_recursive(root_dir, watch_flags, filter=inotify_filter)
            while True:
                for event in inotify.read():
                    print(f"{event.name} changed; updating site")
                    build_site(args.output_root)
        finally:
            server.terminate()
