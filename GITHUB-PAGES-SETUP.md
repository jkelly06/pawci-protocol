# Play PAWCI PROTOCOL on the web

This update adds a single-threaded Godot web export, touchscreen detection, a tap-to-start screen, jump controls, and a GitHub Pages build workflow.

## Publish
1. Open https://github.com/jkelly06/pawci-protocol/settings/pages
2. Under Build and deployment, set Source to GitHub Actions.
3. Extract PAWCI-PROTOCOL-Web-Update.zip on your computer.
4. In the repository, choose Add file > Upload files.
5. Drag the extracted contents into the uploader, including .github and scripts. Keep folders intact. Upload the contents, not the ZIP or an extra enclosing folder.
6. Commit the files to main. Confirm .github/workflows/pages.yml exists in the repository.
7. Open Actions and select Publish PAWCI PROTOCOL. Wait for build and deploy to turn green.
8. If no run starts, select Publish PAWCI PROTOCOL > Run workflow > main > Run workflow.
9. Open https://jkelly06.github.io/pawci-protocol/ after deployment succeeds.

The first build downloads the Godot engine and export templates and may take several minutes. Future commits to main rebuild and publish the game automatically. No token or secret needs to be entered.

## iPhone
Open the published URL in Safari, rotate to landscape, then tap START GAME. Drag on the left to move and on the right to look. Use FIRE, USE, RELOAD, JUMP, and PAUSE on the right. Share the published URL through Messages or email.

## Verification
Godot 4.4.1 imports and exports this update successfully. All 30 native headless gameplay checks passed after the changes. The GitHub workflow has not run on your account yet. Browser and physical iPhone testing are still required; a local browser installation could not complete in the build environment.

The generated browser engine is about 42 MB, larger than GitHub's browser upload limit per file. This workflow builds it within GitHub and publishes it directly, so you only upload these small source updates.
