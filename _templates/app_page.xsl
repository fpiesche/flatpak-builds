<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" version="4.01" indent="yes"/>
<xsl:output doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
<xsl:output doctype-public="-//W3C//DTD HTML 4.01//EN"/>
<xsl:template match="/">
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title><xsl:value-of select="component/name"/></title>
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
      rel="stylesheet"
      integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN"
      crossorigin="anonymous"
    />
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/gh/fpiesche/flatpak-builds/_templates/styles.css" />
  </head>
  <body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
      <div class="container">
        <a class="navbar-brand" href="https://fpiesche.github.io/flatpak-builds/">Florian's Flatpak Repo</a>
      </div>
    </nav>
    <div class="header">
      <div class="container">
      <img
        class="icon"
        height="128px"
        width="128px"
        src='https://raw.githubusercontent.com/fpiesche/flatpak-builds/main/apps/{component/id}/{component/id}.png'
      />
      <button
        type="button"
        class="btn install"
        data-bs-container="body"
        data-bs-toggle="popover"
        data-bs-placement="left"
        data-bs-html="true"
        data-bs-content="flatpak install fpiesche {component/id}"
      >
        Install
      </button>
      <h1><xsl:value-of select="component/name"/></h1>
      <p class="developer">
        by <a href="{component/url}"><xsl:value-of select="component/developer/name"/></a>
      </p>
      </div>
    </div>
      <div id="screenshotCarousel" class="carousel slide">
        <div class="carousel-indicators">
          <xsl:for-each select="component/screenshots/screenshot">
            <xsl:element name="button">
              <xsl:attribute name="type">button</xsl:attribute>
              <xsl:attribute name="data-bs-target">#screenshotCarousel</xsl:attribute>
              <xsl:attribute name="data-bs-slide-to"><xsl:value-of select="position()-1"/></xsl:attribute>
              <xsl:attribute name="aria-label"><xsl:value-of select="caption"/></xsl:attribute>
              <xsl:choose>
                <xsl:when test="@type='default'">
                  <xsl:attribute name="class">active</xsl:attribute>
                  <xsl:attribute name="aria-current">true</xsl:attribute>
                </xsl:when>
              </xsl:choose>
            </xsl:element>
          </xsl:for-each>
        </div>
        <div class="carousel-inner">
        <xsl:for-each select="component/screenshots/screenshot">
          <xsl:element name="div">
          <xsl:choose>
              <xsl:when test="@type!='default' or not(@type)">
                  <xsl:attribute name="class">carousel-item</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:attribute name="class">carousel-item active</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <img src="{image}" class="d-block" alt="{caption}" />
            <div class="carousel-caption d-none d-md-block"><h5><xsl:value-of select="caption"/></h5></div>
          </xsl:element>
        </xsl:for-each>
        </div>
        <button
          class="carousel-control-prev"
          type="button"
          data-bs-target="#screenshotCarousel"
          data-bs-slide="prev"
        >
          <span class="carousel-control-prev-icon" aria-hidden="true"></span>
          <span class="visually-hidden">Previous</span>
        </button>
        <button
          class="carousel-control-next"
          type="button"
          data-bs-target="#screenshotCarousel"
          data-bs-slide="next"
        >
          <span class="carousel-control-next-icon" aria-hidden="true"></span>
          <span class="visually-hidden">Next</span>
        </button>
      </div>

    <div class="container my-5">
    <h1><xsl:value-of select="component/name"/></h1>
    <div class="col-lg-8 px-0">
      <p class="fs-5">
        <xsl:copy-of select="component/description"/>
      </p>
    </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js"></script>
    <script
      src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"
      integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL"
      crossorigin="anonymous"
    ></script>
    <script>
    const popoverTriggerList = document.querySelectorAll(
      '[data-bs-toggle="popover"]'
    );
    const popoverList = [...popoverTriggerList].map(
      (popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl)
    );
    </script>
  </body>
</html>

</xsl:template>
</xsl:stylesheet>
