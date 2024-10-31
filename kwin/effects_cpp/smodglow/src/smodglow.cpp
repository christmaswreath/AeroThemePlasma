/*
 * based on Kwin Feedback effect
 * based on StartupId in KRunner by Lubos Lunak
 *
 * SPDX-FileCopyrightText: 2001 Lubos Lunak <l.lunak@kde.org>
 * SPDX-FileCopyrightText: 2010 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2020 David Redondo <kde@david-redondo.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "smodglow.h"
#include "smod.h"

#include <SMOD/Decoration/BreezeDecoration>


#define TESTING_NEW_DPI 0
#define RIGHT_SIDE_ORIGIN 0

// TODO remove "+ 1.0" when I fix the textures
#define MINMAXGLOW_SML 9.0 + 1.0
#define MINMAXGLOW_SMT 8.0 + 1.0
#define CLOSEGLOW_SML  9.0 + 1.0
#define CLOSEGLOW_SMT  8.0 + 1.0

// internally the SMOD decoration is in the Breeze namespace
// use a typedef to avoid confusion
typedef Breeze::Decoration SmodDecoration;


//Q_LOGGING_CATEGORY(KWIN_EFFECT_SMODWINDOWBUTTONS, "kwin.effect.smodglow", QtWarningMsg)

static void ensureResources()
{
    Q_INIT_RESOURCE(smodglow);
}

namespace KWin
{

SmodGlowEffect::SmodGlowEffect()
{
    setupEffectHandlerConnections();

    reconfigure(ReconfigureAll);

    // NOTE is this needed?
    //effects->makeOpenGLContextCurrent();

    m_shader = ShaderManager::instance()->generateShaderFromFile(
        ShaderTrait::MapTexture,
        QString(),
        QStringLiteral(":/effects/smodglow/shaders/shader.frag")
    );
}

SmodGlowEffect::~SmodGlowEffect()
{
}

bool SmodGlowEffect::supported()
{
    return effects->isOpenGLCompositing();
}

void SmodGlowEffect::reconfigure(Effect::ReconfigureFlags flags)
{
    Q_UNUSED(flags)

    ensureResources();

    m_active = SMOD::registerResource(QStringLiteral("smodgloweffecttextures"));

    if (!isActive())
    {
        qDebug() << "kwin_effect_smodglow: SMOD RCC \"smodgloweffecttextures\" not found!";

        return;
    }

    loadTextures();

    const auto windowlist = effects->stackingOrder();

    for (EffectWindow *window : windowlist)
    {
        unregisterWindow(window);
        registerWindow(window);
    }
}

void SmodGlowEffect::setupEffectHandlerConnections()
{
    connect(effects, &EffectsHandler::windowAdded, this, &SmodGlowEffect::windowAdded);
    connect(effects, &EffectsHandler::windowClosed, this, &SmodGlowEffect::windowClosed);
#ifndef BUILD_KF6
    connect(effects, &EffectsHandler::windowMaximizedStateChanged, this, &SmodGlowEffect::windowMaximizedStateChanged);
    connect(effects, &EffectsHandler::windowMinimized, this, &SmodGlowEffect::windowMinimized);
    connect(effects, &EffectsHandler::windowStartUserMovedResized, this, &SmodGlowEffect::windowStartUserMovedResized);
    connect(effects, &EffectsHandler::windowFullScreenChanged, this, &SmodGlowEffect::effectWindowFullScreenChanged);
    connect(effects, &EffectsHandler::windowDecorationChanged, this, &SmodGlowEffect::windowDecorationChanged);
#endif
}

void SmodGlowEffect::setupEffectWindowConnections(const EffectWindow *w)
{
#ifdef BUILD_KF6
    connect(w, &EffectWindow::windowMaximizedStateChanged, this, &SmodGlowEffect::windowMaximizedStateChanged);
    connect(w, &EffectWindow::minimizedChanged, this, &SmodGlowEffect::windowMinimized);
    connect(w, &EffectWindow::windowStartUserMovedResized, this, &SmodGlowEffect::windowStartUserMovedResized);
    connect(w, &EffectWindow::windowFullScreenChanged, this, &SmodGlowEffect::effectWindowFullScreenChanged);
    connect(w, &EffectWindow::windowDecorationChanged, this, &SmodGlowEffect::windowDecorationChanged);
#endif
}

void SmodGlowEffect::registerWindow(const EffectWindow *w)
{
    if (!w || windows.contains(w) || !w->hasDecoration())
    {
        return;
    }

    // In order to access our custom signal we need to cast to the correct class
    SmodDecoration *smoddecoration = qobject_cast<SmodDecoration*>(w->decoration());

    // if the cast was unsuccessful (the loaded decoration plugin is not SMOD) then return
    if (!smoddecoration)
    {
        return;
    }

    // Attempt to connect to the decoration signal.
#if TESTING_NEW_DPI
    auto connection = QObject::connect(smoddecoration, &SmodDecoration::buttonHoveredChanged, this,
        [w, this](KDecoration2::DecorationButtonType button, bool hovered, QPoint pos, int dpi) {
#else
    auto connection = QObject::connect(smoddecoration, &SmodDecoration::buttonHoverStatus, this,
        [w, this](KDecoration2::DecorationButtonType button, bool hovered, QPoint pos) {
        int dpi = m_current_dpi;
#endif

        GlowAnimationHandler *anim;

        switch (button)
        {
            case KDecoration2::DecorationButtonType::Minimize:
            {
                anim = this->windows.value(w)->m_min;

#if RIGHT_SIDE_ORIGIN
                anim->pos = -(pos + QPoint(MINMAXGLOW_SML, MINMAXGLOW_SMT));
#else
                anim->pos = pos - QPoint(MINMAXGLOW_SML, MINMAXGLOW_SMT);
#endif
                break;
            }
            case KDecoration2::DecorationButtonType::Maximize:
            {
                anim = this->windows.value(w)->m_max;
#if RIGHT_SIDE_ORIGIN
                anim->pos = -(pos + QPoint(MINMAXGLOW_SML, MINMAXGLOW_SMT));
#else
                anim->pos = pos - QPoint(MINMAXGLOW_SML, MINMAXGLOW_SMT);
#endif
                break;
            }
            case KDecoration2::DecorationButtonType::Close:
            {
                anim = this->windows.value(w)->m_close;
#if RIGHT_SIDE_ORIGIN
                anim->pos = -(pos + QPoint(CLOSEGLOW_SML, CLOSEGLOW_SMT));
#else
                anim->pos = pos - QPoint(CLOSEGLOW_SML, CLOSEGLOW_SMT);
#endif
                break;
            }
            default:
            {
                return;
            }
        }

        if (dpi != m_current_dpi)
        {
            m_next_dpi = (WindowButtonsDPI)dpi;
            m_needsDpiChange = true;
        }

        anim->startHoverAnimation(hovered ? 1.0 : 0.0);
    });

    if (!connection)
    {
        return;
    }

    auto glowhandler = new GlowHandler(this);
    glowhandler->m_decoration_connection = connection;
    windows.insert(w, glowhandler);

    setupEffectWindowConnections(w);
}

void SmodGlowEffect::unregisterWindow(const EffectWindow *w)
{
    if (windows.contains(w))
    {
        windows.value(w)->stopAll();
        QObject::disconnect(windows.value(w)->m_decoration_connection);
        windows.remove(w);
    }
}

void SmodGlowEffect::stopAllAnimations(const EffectWindow *w)
{
    if (windows.contains(w))
    {
        windows.value(w)->stopAll();
    }
}

void SmodGlowEffect::prePaintWindow(EffectWindow *w, WindowPrePaintData &data, std::chrono::milliseconds presentTime)
{
    effects->prePaintWindow(w, data, presentTime);

    if(w->isUserResize())
    {
        stopAllAnimations(w);
        return;
    }
    if (!windows.contains(w))
    {
        return;
    }

    if (m_needsDpiChange)
    {
        loadTextures();
    }

    GlowHandler *handler = windows.value(w);

    if (!handler->m_needsRepaint)
    {
        return;
    }

#if RIGHT_SIDE_ORIGIN
    QPoint origin = w->frameGeometry().topLeft().toPoint() + QPoint(w->frameGeometry().width(), 0);
#else
    auto maximizeState = w->window()->maximizeMode();
    int diff = 0;//w->frameGeometry().width() - (handler->m_close->pos.x() + m_texture_close.get()->size().width()) + 3;

    if(maximizeState == KWin::MaximizeMode::MaximizeFull)
        diff = -2;

    QPoint origin = w->pos().toPoint();
    origin += QPoint(diff, 0);
#endif
    handler->m_min_rect   = QRect(origin + handler->m_min->pos,   m_texture_minimize.get()->size());
    handler->m_max_rect   = QRect(origin + handler->m_max->pos,   m_texture_maximize.get()->size());
    handler->m_close_rect = QRect(origin + handler->m_close->pos, m_texture_close.get()->size());

    QRegion newPaint = QRegion();
    newPaint |= handler->m_min_rect;
    newPaint |= handler->m_max_rect;
    newPaint |= handler->m_close_rect;

    if (newPaint != m_prevPaint)
    {
        QRegion clearRegion = m_prevPaint - newPaint;

        if (!clearRegion.isEmpty())
        {
            data.paint |= clearRegion;
        }
    }

    data.paint |= newPaint;
    m_prevPaint = newPaint;
}

void SmodGlowEffect::postPaintWindow(EffectWindow *w)
{
    if (windows.contains(w))
    {
        GlowHandler *handler = windows.value(w);

        if (handler->m_needsRepaint)
        {
            effects->addRepaint(m_prevPaint);
        }
    }

    effects->postPaintWindow(w);
}

void SmodGlowEffect::windowAdded(EffectWindow *w)
{
    registerWindow(w);
}

void SmodGlowEffect::windowClosed(EffectWindow *w)
{
    unregisterWindow(w);
}

void SmodGlowEffect::windowMaximizedStateChanged(EffectWindow *w, bool horizontal, bool vertical)
{
    Q_UNUSED(horizontal)
    Q_UNUSED(vertical)

    stopAllAnimations(w);
}

void SmodGlowEffect::windowMinimized(EffectWindow *w)
{
    stopAllAnimations(w);
}

void SmodGlowEffect::windowStartUserMovedResized(EffectWindow *w)
{
    stopAllAnimations(w);
}

void SmodGlowEffect::effectWindowFullScreenChanged(EffectWindow *w)
{
    /*
     * When a window goes fullscreen the decoration connection is lost.
     * Just need to register the window again.
     */
    unregisterWindow(w);
    registerWindow(w);
}

void SmodGlowEffect::windowDecorationChanged(EffectWindow *w)
{
    /*
     * Ditto
     */
    unregisterWindow(w);
    registerWindow(w);
}

}